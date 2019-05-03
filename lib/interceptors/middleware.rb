module Interceptors
  class Middleware
    attr_reader :on_enter, :on_leave

    def initialize
      @on_enter = Queue.new
      @on_leave = DS::Stack.new
    end

    # Queue operations
    def enqueue(element)
      on_enter.push(element)
    end

    def dequeue
      on_enter.pop
    end

    # Stack operations
    def push(element)
      on_leave.push(element)
    end

    def pop
      on_leave.pop
    end
  end
end
