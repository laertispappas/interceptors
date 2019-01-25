require_relative "./errors"

module Interceptors
  module DS
    class Stack
      include DS::Errors

      def initialize
        @head = nil
      end

      def push(item)
        assert!(item)
        old_head = @head
        @head = Node.new(item)
        @head.next = old_head
      end

      def pop
        raise NoSuchElementException if empty?

        @head.item.tap { @head = @head.next }
      end

      def empty?
        @head.nil?
      end
    end
  end
end
