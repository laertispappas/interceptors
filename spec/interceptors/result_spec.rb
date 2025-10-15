# frozen_string_literal: true

require "spec_helper"

RSpec.describe Interceptors::Result do
  describe ".ok" do
    it "creates an ok result with value" do
      result = described_class.ok("value", meta: { source: "spec" })

      expect(result).to be_ok
      expect(result.value).to eq("value")
      expect(result.meta[:source]).to eq("spec")
      expect(result.error).to be_nil
    end
  end

  describe ".err" do
    it "creates an error result with metadata" do
      error = StandardError.new("something went wrong")
      result = described_class.err(error, meta: { trace_id: "abc" })

      expect(result).to be_err
      expect(result.error).to eq(error)
      expect(result.meta[:trace_id]).to eq("abc")
    end

    it "raises when error is missing" do
      expect { described_class.err(nil) }.to raise_error(ArgumentError)
    end
  end

  describe "#merge_meta" do
    it "returns a new result with merged metadata" do
      original = described_class.ok("value", meta: { trace_id: "a" })
      merged = original.merge_meta(user: 1)

      expect(merged).not_to equal(original)
      expect(merged.meta).to include(trace_id: "a", user: 1)
      expect(original.meta).to eq(trace_id: "a")
    end
  end
end
