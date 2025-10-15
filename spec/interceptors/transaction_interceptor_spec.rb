# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::TransactionInterceptor do
  it "yields directly when no adapter is available" do
    interceptor = described_class.new(adapter: nil)

    expect(interceptor.around({}) { :value }).to eq(:value)
  end

  it "wraps execution within a provided adapter" do
    calls = []
    adapter = lambda do |&block|
      calls << :begin
      value = block.call
      calls << :commit
      value
    end

    interceptor = described_class.new(adapter: adapter)
    result = interceptor.around({}) { calls << :execute; :value }

    expect(result).to eq(:value)
    expect(calls).to eq(%i[begin execute commit])
  end
end
