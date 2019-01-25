# frozen_string_literal: true

require "spec_helper"

module Interceptors
  module DS
    RSpec.describe Middleware, type: :model do
      let(:mw) { described_class.new }

      it { expect(mw.on_enter).to be_empty }
      it { expect(mw.on_leave).to be_empty }

      it { expect(mw.on_enter).to be_a Queue }
      it { expect(mw.on_leave).to be_a DS::Stack }

      describe "#enqueue" do
        it "should enqueue an element to the on_enter queue" do
          mw.enqueue(1)

          expect(mw.on_enter).to_not be_empty
          expect(mw.on_leave).to be_empty
        end
      end

      describe "#dequeue" do
        it "should dequeue from the on_enter queue" do
          element = double("some service")
          mw.enqueue(element)
          expect(mw.dequeue).to eq element

          expect(mw.on_enter).to be_empty
          expect(mw.on_leave).to be_empty
        end
      end

      describe "#push" do
        it "should push an element to the on_leave stack" do
          mw.push(1)

          expect(mw.on_enter).to be_empty
          expect(mw.on_leave).to_not be_empty
        end
      end

      describe "#pop" do
        it "should dequeue from the on_leave stack" do
          element = double("some service")
          mw.push(element)
          expect(mw.pop).to eq element

          expect(mw.on_enter).to be_empty
          expect(mw.on_leave).to be_empty
        end
      end
    end
  end
end
