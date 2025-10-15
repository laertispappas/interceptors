# frozen_string_literal: true

module Interceptors
  class TransactionInterceptor < Interceptor
    def initialize(adapter: default_adapter)
      @adapter = adapter
    end

    def around(ctx)
      return yield ctx unless @adapter

      @adapter.call { yield ctx }
    end

    private

    def default_adapter
      return nil unless defined?(ActiveRecord::Base)
      return nil unless ActiveRecord::Base.respond_to?(:connection)

      lambda do |&block|
        ActiveRecord::Base.transaction(&block)
      end
    end
  end
end
