module Interceptors
  module DS
    module Errors
      Error = Class.new(StandardError)
      class NullValueNotAllowedError < Error; end
      class NoSuchElementException < Error; end

      private

      def assert!(item)
        raise NullValueNotAllowedError, "A value must not be null in the dequeue" if item.nil?
      end
    end
  end
end
