# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::UseCase do
  before do
    Interceptors.configure do |config|
      config.notification_namespace = "use_case"
    end
    Interceptors::IdempotencyInterceptor::DEFAULT_STORE.clear
  end

  describe ".call" do
    it "wraps plain return values in an ok result" do
      klass = Class.new(described_class) do
        def execute(ctx)
          ctx[:value] * 2
        end
      end

      result = klass.call(value: 10)

      expect(result).to be_ok
      expect(result.value).to eq(20)
    end

    it "treats nil return values as ok results" do
      klass = Class.new(described_class) do
        def execute(_ctx); end
      end

      result = klass.call({})

      expect(result).to be_ok
      expect(result.value).to be_nil
    end

    it "accepts inputs that respond to #to_h" do
      klass = Class.new(described_class) do
        def execute(ctx)
          Interceptors::Result.ok(ctx[:foo])
        end
      end

      payload = Struct.new(:foo) do
        def to_h
          { foo: foo }
        end
      end

      result = klass.call(payload.new("bar"))

      expect(result).to be_ok
      expect(result.value).to eq("bar")
    end

    it "runs registered interceptors in order" do
      events = []

      recorder = Class.new(Interceptors::Interceptor) do
        def initialize(events, name)
          @events = events
          @name = name
        end

        def before(_ctx)
          @events << "before:#{@name}"
        end

        def around(ctx)
          @events << "around:#{@name}:enter"
          result = yield ctx
          @events << "around:#{@name}:exit"
          result
        end

        def after(_ctx, result)
          @events << "after:#{@name}"
          result
        end
      end

      klass = Class.new(described_class) do
        use recorder.new(events, "A")
        use recorder.new(events, "B")

        def execute(_ctx)
          Interceptors::Result.ok("done")
        end
      end

      result = klass.call(value: 1)

      expect(result.value).to eq("done")
      expect(events).to eq(
        [
          "before:A",
          "around:A:enter",
          "before:B",
          "around:B:enter",
          "around:B:exit",
          "after:B",
          "around:A:exit",
          "after:A"
        ]
      )
    end

    it "emits instrumentation events" do
      start_payloads = []
      finish_payloads = []

      start_sub = ActiveSupport::Notifications.subscribe("use_case.start") do |*_args, payload|
        start_payloads << payload
      end

      finish_sub = ActiveSupport::Notifications.subscribe("use_case.finish") do |*_args, payload|
        finish_payloads << payload
      end

      klass = Class.new(described_class) do
        def execute(_ctx)
          :ok
        end
      end

      klass.call(foo: "bar")

      expect(start_payloads.size).to eq(1)
      expect(finish_payloads.size).to eq(1)
      expect(start_payloads.first[:ctx]).to include(foo: "bar")
      expect(finish_payloads.first[:ok]).to eq(true)
    ensure
      ActiveSupport::Notifications.unsubscribe(start_sub)
      ActiveSupport::Notifications.unsubscribe(finish_sub)
    end

    it "returns an err result when execute raises a known app error" do
      klass = Class.new(described_class) do
        def execute(_ctx)
          raise Interceptors::ValidationError.new(email: "invalid")
        end
      end

      result = klass.call({})

      expect(result).to be_err
      expect(result.error).to be_a(Interceptors::ValidationError)
      expect(result.error.details).to eq(email: "invalid")
    end

    it "emits an error notification when an app error occurs" do
      payloads = []
      subscriber = ActiveSupport::Notifications.subscribe("use_case.error") do |*_args, payload|
        payloads << payload
      end

      klass = Class.new(described_class) do
        def execute(_ctx)
          raise Interceptors::ValidationError.new(email: "invalid")
        end
      end

      klass.call({})

      expect(payloads).not_to be_empty
      expect(payloads.first[:code]).to eq("validation_failed")
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

    it "wraps unexpected exceptions in a generic app error" do
      klass = Class.new(described_class) do
        def execute(_ctx)
          raise "boom"
        end
      end

      result = klass.call({})

      expect(result).to be_err
      expect(result.error).to be_a(Interceptors::AppError)
      expect(result.error.code).to eq("unhandled_exception")
      expect(result.error.http_status).to eq(500)
    end

    it "merges default context into the execution context" do
      klass = Class.new(described_class) do
        attr_reader :captured_ctx

        def default_context
          { default: true }
        end

        def execute(ctx)
          @captured_ctx = ctx
          Interceptors::Result.ok
        end
      end

      instance = klass.new
      instance.call(custom: "value")

      expect(instance.captured_ctx).to include(default: true, custom: "value")
      expect(instance.captured_ctx).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end
  end
end
