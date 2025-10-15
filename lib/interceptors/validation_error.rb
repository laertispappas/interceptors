# frozen_string_literal: true

module Interceptors
  class ValidationError < AppError
    def initialize(details = nil, message: "Validation failed", code: "validation_failed", http_status: 422, **keywords)
      payload = if details.nil?
                  {}
                elsif details.respond_to?(:to_hash)
                  details.to_hash
                else
                  { base: Array(details) }
                end

      payload.merge!(keywords) unless keywords.empty?

      super(message, code: code, http_status: http_status, details: payload)
    end
  end
end
