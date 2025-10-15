# frozen_string_literal: true

module Interceptors
  class ValidationInterceptor < Interceptor
    def initialize(&block)
      raise ArgumentError, "validation block is required" unless block

      @validator = block
    end

    def before(ctx)
      errors = normalize_errors(@validator.call(ctx))
      raise ValidationError.new(errors) if errors.any?
    end

    private

    def normalize_errors(value)
      return {} if value.nil?
      return value if value.is_a?(Hash)
      return value.to_hash if value.respond_to?(:to_hash)
      return value.to_h if value.respond_to?(:to_h)

      { base: Array(value) }
    end
  end
end
