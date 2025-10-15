# frozen_string_literal: true

module Interceptors
  class RetryInterceptor < Interceptor
    def initialize(tries: 3, on: [StandardError], base_delay: 0.05, max_delay: 0.5)
      raise ArgumentError, "tries must be >= 1" unless tries.to_i >= 1

      @tries = tries.to_i
      @exceptions = Array(on)
      @base_delay = base_delay.to_f
      @max_delay = max_delay.to_f
    end

    def around(ctx)
      attempt = 0

      begin
        attempt += 1
        yield ctx
      rescue => e
        raise unless @exceptions.any? { |klass| e.is_a?(klass) }

        return Result.err(e) if attempt >= @tries

        Kernel.sleep(delay_for_attempt(attempt))
        retry
      end
    end

    private

    def delay_for_attempt(attempt)
      [@base_delay * (2**(attempt - 1)), @max_delay].min
    end
  end
end
