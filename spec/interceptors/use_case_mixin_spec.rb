# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::UseCaseMixin do
  it "provides interceptor DSL when included" do
    klass = Class.new do
      include Interceptors::UseCaseMixin

      use Interceptors::ValidationInterceptor.new { {} }

      def execute(ctx)
        Interceptors::Result.ok(ctx[:value])
      end
    end

    result = klass.call(value: 123)

    expect(result).to be_ok
    expect(result.value).to eq(123)
  end

  it "duplicates interceptors for subclasses" do
    base = Class.new do
      include Interceptors::UseCaseMixin
      use Interceptors::LoggingInterceptor.new

      def execute(*)
        Interceptors::Result.ok("base")
      end
    end

    child = Class.new(base) do
      def execute(*)
        Interceptors::Result.ok("child")
      end
    end

    expect(child.interceptors.length).to eq(base.interceptors.length)
    expect(child.interceptors).not_to equal(base.interceptors)
  end
end
