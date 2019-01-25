module Interceptors
  module DS
    class Node
      attr_accessor :next, :item

      def initialize(item)
        @item = item
        @next = nil
      end
    end
  end
end
