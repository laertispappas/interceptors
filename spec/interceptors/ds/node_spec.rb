# frozen_string_literal: true

require "spec_helper"

module Interceptors
  module DS
    RSpec.describe Node, type: :model do
      let(:node) { described_class.new(item) }
      let(:item) { double("Item") }

      it { expect(node.item).to eq item }
      it { expect(node.next).to be_nil }

      it "sets next" do
        _next = Node.new(2)
        node.next = _next

        expect(node.next).to eq _next
        expect(node.next.next).to eq nil
      end
    end
  end
end
