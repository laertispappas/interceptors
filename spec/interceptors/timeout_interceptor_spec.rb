# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::TimeoutInterceptor do
  it "returns an error result when the block times out" do
    interceptor = described_class.new(seconds: 1)

    allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)

    result = interceptor.around({}) { Interceptors::Result.ok("done") }

    expect(result).to be_err
    expect(result.error.code).to eq("timeout")
    expect(result.error.http_status).to eq(504)
  end
end
