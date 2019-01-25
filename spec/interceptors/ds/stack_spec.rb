# frozen_string_literal: true

require "spec_helper"

module Interceptors
  module DS
    RSpec.describe Stack, type: :model do
      let(:stack) { described_class.new }

      describe "#push & #pop" do
        it "should enqueue the element in the queue in a FIFO manner" do
          stack.push 1
          stack.push 2
          stack.push 3

          expect(stack.pop).to eq 3
          expect(stack.pop).to eq 2
          expect(stack.pop).to eq 1
        end
      end

      describe "#dequeue" do
        it "raised an exception when the queue is empty" do
          expect { stack.pop }.to raise_error(Interceptors::DS::Errors::NoSuchElementException)
        end
      end

      describe "#empty?" do
        it "is empty by default" do
          expect(stack).to be_empty
        end

        it "is not empty when at least one element exist in the queue" do
          stack.push 1
          expect(stack).not_to be_empty

          stack.pop
          expect(stack).to be_empty
        end
      end
    end
  end
end
