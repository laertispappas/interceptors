# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::RetryInterceptor do
  before do
    allow(Kernel).to receive(:sleep)
  end

  it "retries until the block succeeds" do
    attempts = 0

    interceptor = described_class.new(tries: 3, on: [RuntimeError], base_delay: 0.0, max_delay: 0.0)

    result = interceptor.around({}) do
      attempts += 1
      raise RuntimeError, "fail" if attempts < 3

      Interceptors::Result.ok("success")
    end

    expect(result).to be_ok
    expect(result.value).to eq("success")
    expect(attempts).to eq(3)
  end

  it "returns an err result after exhausting retries" do
    attempts = 0

    interceptor = described_class.new(tries: 2, on: [RuntimeError], base_delay: 0.0, max_delay: 0.0)

    result = interceptor.around({}) do
      attempts += 1
      raise RuntimeError, "fail"
    end

    expect(result).to be_err
    expect(result.error).to be_a(RuntimeError)
    expect(attempts).to eq(2)
  end

  it "re-raises errors that are not configured for retry" do
    interceptor = described_class.new(tries: 2, on: [RuntimeError])

    expect do
      interceptor.around({}) { raise ArgumentError, "boom" }
    end.to raise_error(ArgumentError)
  end
end
