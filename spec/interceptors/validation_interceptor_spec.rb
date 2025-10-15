# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::ValidationInterceptor do
  it "raises validation error when block returns issues" do
    interceptor = described_class.new { { email: "is invalid" } }

    expect do
      interceptor.before({ email: "bad" })
    end.to raise_error(Interceptors::ValidationError) do |error|
      expect(error.details).to eq(email: "is invalid")
    end
  end

  it "passes through when validator returns no errors" do
    interceptor = described_class.new { {} }

    expect { interceptor.before({}) }.not_to raise_error
  end
end
