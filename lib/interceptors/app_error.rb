# frozen_string_literal: true

module Interceptors
  class AppError < StandardError
    attr_reader :code, :details, :http_status

    def initialize(message = "Application error", code: "app_error", http_status: 400, details: {})
      super(message)
      @code = code
      @http_status = http_status
      @details = details || {}
    end

    def to_h
      {
        message: message,
        code: code,
        http_status: http_status,
        details: details
      }
    end
  end
end
