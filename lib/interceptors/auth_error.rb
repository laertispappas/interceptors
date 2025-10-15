# frozen_string_literal: true

module Interceptors
  class AuthError < AppError
    def initialize(message: "Unauthorized", code: "unauthorized", http_status: 401, details: {})
      super(message, code: code, http_status: http_status, details: details)
    end
  end
end
