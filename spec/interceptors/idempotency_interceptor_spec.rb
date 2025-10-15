# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::IdempotencyInterceptor do
  let(:store) { described_class::MemoryStore.new }
  let(:key_proc) { ->(ctx) { ctx[:key] } }

  it "returns cached result for repeated calls within TTL" do
    interceptor = described_class.new(key_proc: key_proc, ttl: 300, store: store)
    counter = 0

    first = interceptor.around(key: "abc") do
      counter += 1
      Interceptors::Result.ok(counter)
    end

    second = interceptor.around(key: "abc") do
      counter += 1
      Interceptors::Result.ok(counter)
    end

    expect(first.value).to eq(1)
    expect(second.value).to eq(1)
    expect(counter).to eq(1)
  end

  it "expires cached results after TTL" do
    interceptor = described_class.new(key_proc: key_proc, ttl: 1, store: store)
    counter = 0

    allow(Time).to receive(:now).and_return(Time.at(0), Time.at(2), Time.at(2))

    interceptor.around(key: "abc") do
      counter += 1
      Interceptors::Result.ok(counter)
    end

    interceptor.around(key: "abc") do
      counter += 1
      Interceptors::Result.ok(counter)
    end

    expect(counter).to eq(2)
  end

  it "ignores non-result responses" do
    interceptor = described_class.new(key_proc: key_proc, ttl: 300, store: store)

    value = interceptor.around(key: "abc") { :not_a_result }

    expect(value).to eq(:not_a_result)
    expect(store.read("abc")).to be_nil
  end
end
