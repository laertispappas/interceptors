# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::ValidationError do
  it "accepts keyword details" do
    error = described_class.new(email: "invalid")

    expect(error.details).to eq(email: "invalid")
    expect(error.code).to eq("validation_failed")
  end

  it "merges hash and keyword details" do
    error = described_class.new({ email: "invalid" }, password: "too short")

    expect(error.details).to eq(email: "invalid", password: "too short")
  end

  it "coerces non-hash details into a base entry" do
    error = described_class.new("boom")

    expect(error.details).to eq(base: ["boom"])
  end
end
