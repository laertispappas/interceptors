# frozen_string_literal: true

require "timeout"

module Interceptors
  class TimeoutInterceptor < Interceptor
    def initialize(seconds:)
      raise ArgumentError, "seconds must be positive" unless seconds.to_f.positive?

      @seconds = seconds.to_f
    end

    def around(ctx)
      Timeout.timeout(@seconds) { yield ctx }
    rescue Timeout::Error
      Result.err(AppError.new("Timeout", code: "timeout", http_status: 504))
    end
  end
end
