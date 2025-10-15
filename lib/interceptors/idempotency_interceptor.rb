# frozen_string_literal: true

require "thread"

module Interceptors
  class IdempotencyInterceptor < Interceptor
    class MemoryStore
      def initialize
        @data = {}
        @mutex = Mutex.new
      end

      def read(key)
        @mutex.synchronize { @data[key] }
      end

      def write(key, value, ttl: nil)
        @mutex.synchronize { @data[key] = value }
        value
      end

      def delete(key)
        @mutex.synchronize { @data.delete(key) }
      end

      def clear
        @mutex.synchronize { @data.clear }
      end
    end

    DEFAULT_STORE = MemoryStore.new

    def initialize(key_proc:, ttl: 300, store: DEFAULT_STORE)
      raise ArgumentError, "key_proc must be callable" unless key_proc.respond_to?(:call)

      @key_proc = key_proc
      @ttl = ttl.to_i
      @store = store
    end

    def around(ctx)
      key = safe_key(ctx)
      return yield ctx unless key

      cached = @store.read(key)
      return cached if fresh?(cached)

      result = yield ctx
      return result unless result.is_a?(Result)
      return result unless result.ok?

      stored = result.merge_meta(stored_at: Time.now.to_i)
      @store.write(key, stored, ttl: @ttl)
      stored
    end

    private

    def safe_key(ctx)
      @key_proc.call(ctx)
    rescue StandardError
      nil
    end

    def fresh?(result)
      return false unless result.is_a?(Result)
      return false unless @ttl.positive?

      stored_at = result.meta[:stored_at]
      return false unless stored_at

      (Time.now.to_i - stored_at.to_i) < @ttl
    end
  end
end
