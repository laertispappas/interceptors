# frozen_string_literal: true

module Interceptors
  class Result
    attr_reader :value, :error, :meta

    def initialize(value: nil, error: nil, meta: {})
      @value = value
      @error = error
      @meta = meta || {}
    end

    def ok?
      error.nil?
    end

    def err?
      !ok?
    end

    def self.ok(value = nil, meta: {})
      new(value: value, meta: meta)
    end

    def self.err(error, meta: {})
      raise ArgumentError, "error must be provided" if error.nil?

      new(error: error, meta: meta)
    end

    def merge_meta(extra)
      self.class.new(value: value, error: error, meta: meta.merge(extra))
    end

    def to_h
      { value: value, error: error, meta: meta }
    end
  end
end
