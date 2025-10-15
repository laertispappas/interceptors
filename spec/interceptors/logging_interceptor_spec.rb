# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::LoggingInterceptor do
  let(:logger) { instance_double("Logger", info: true) }

  before do
    Interceptors.configure do |config|
      config.notification_namespace = "use_case"
    end
  end

  it "instruments before and after events" do
    payloads = []
    subscriber = ActiveSupport::Notifications.subscribe("use_case.log") do |*_args, payload|
      payloads << payload
    end

    interceptor = described_class.new(logger: logger)
    pipeline = Interceptors::Pipeline.new([interceptor])
    result = pipeline.call({}) { Interceptors::Result.ok("done") }

    expect(result).to be_ok
    expect(payloads.map { |p| p[:stage] }).to eq(%i[before after])
    expect(logger).to have_received(:info).twice
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
