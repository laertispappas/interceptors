module Interceptors
  class Executor
    attr_reader :middleware, :context

    def initialize(context = Context.new)
      @middleware = Middleware.new
      @context = context
    end

    def register(interceptor)
      middleware.enqueue(interceptor)
    end

    def call
      while (interceptor, step = fetch_next)
        with_exception_handling(interceptor) do
          interceptor.public_send(step, context)
        end
      end

      context
    end

    private

    def fetch_next
      if context[:error]
        [middleware.pop, :on_error] unless middleware.on_leave.empty?
      elsif !middleware.on_enter.empty?
        interceptor = middleware.dequeue
        middleware.push(interceptor)
        [interceptor, :on_enter]
      elsif !middleware.on_leave.empty?
        [middleware.pop, :on_leave]
      end
    end

    def with_exception_handling(interceptor)
      yield
    rescue StandardError => e
      context[:error] = e
      context[:error_raised_at] = interceptor.class.name
    end
  end
end
