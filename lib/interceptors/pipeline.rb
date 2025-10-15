# frozen_string_literal: true

module Interceptors
  class Pipeline
    def initialize(interceptors)
      @interceptors = Array(interceptors)
    end

    def call(ctx, &final_handler)
      raise ArgumentError, "a final handler block is required" unless final_handler

      chain = @interceptors.reverse.inject(final_handler) do |acc, interceptor|
        proc do |inner_ctx|
          interceptor.before(inner_ctx)
          result = interceptor.around(inner_ctx) { |next_ctx| acc.call(next_ctx) }
          interceptor.after(inner_ctx, result) || result
        end
      end

      chain.call(ctx)
    end
  end
end
