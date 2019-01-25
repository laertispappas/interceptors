# frozen_string_literal: true

require "spec_helper"

module Interceptors
  RSpec.describe Executor do
    let(:executor) { Executor.new }
    let(:context) { executor.context }

    let(:on_enter) { executor.middleware.on_enter }
    let(:on_leave) { executor.middleware.on_leave }

    it { expect(executor.middleware.on_enter).to be_empty }
    it { expect(executor.middleware.on_leave).to be_empty }

    describe "#register" do
      let(:interceptor_1) { double(1) }
      let(:interceptor_2) { double(2) }

      before do
        executor.register(interceptor_1)
        executor.register(interceptor_2)
      end

      it { expect(on_enter).to_not be_empty }
      it { expect(on_leave).to be_empty }

      it "includes the first interceptor" do
        expect(on_enter.deq).to eq interceptor_1
      end

      it "includes the second interceptor" do
        on_enter.deq
        expect(on_enter.deq).to eq interceptor_2
      end

      it "is empty after 2 dequeues" do
        on_enter.deq
        on_enter.deq
        expect(on_enter).to be_empty
      end
    end

    describe "#call" do
      context "when no error is raised" do
        it "calls an interceptor with 1 on enter defined" do
          executor.register(InterceptorsHelper::TestEnter.new(:a))
          executor.call

          expect(context[:a][:on_enter]).to eq 1
          expect(context[:a]).not_to have_key(:on_leave)
          expect(context[:a]).not_to have_key(:on_error)
        end

        it "calls an interceptori that defines both the on enter and on leave method" do
          executor.register(InterceptorsHelper::TestEnterLeave.new(:a))
          executor.call

          expect(context[:a][:on_enter]).to eq 1
          expect(context[:a][:on_leave]).to eq 1
          expect(context[:a]).not_to have_key(:on_error)
        end

        it "calls an interceptor with 1 on leave defined" do
          executor.register(InterceptorsHelper::TestLeave.new(:a))
          executor.call

          expect(context[:a][:on_leave]).to eq 1
          expect(context[:a]).not_to have_key(:on_enter)
          expect(context[:a]).not_to have_key(:on_error)
        end

        it "calls an interceptors with enter and leave mw" do
          executor.register(InterceptorsHelper::TestEnter.new(:a))
          executor.register(InterceptorsHelper::TestLeave.new(:b))
          executor.register(InterceptorsHelper::TestEnter.new(:c))
          executor.register(InterceptorsHelper::TestLeave.new(:d))
          executor.call

          expect(context[:a][:on_enter]).to eq 1
          expect(context[:a]).not_to have_key(:on_leave)
          expect(context[:a]).not_to have_key(:on_error)

          expect(context[:b][:on_leave]).to eq 1
          expect(context[:b]).not_to have_key(:on_enter)
          expect(context[:b]).not_to have_key(:on_error)

          expect(context[:c][:on_enter]).to eq 1
          expect(context[:c]).not_to have_key(:on_leave)
          expect(context[:c]).not_to have_key(:on_error)

          expect(context[:d][:on_leave]).to eq 1
          expect(context[:d]).not_to have_key(:on_enter)
          expect(context[:d]).not_to have_key(:on_error)
        end
      end

      context "when an error is raised" do
        it "calls all on error methods in the stack" do
          executor.register(InterceptorsHelper::TestEnterLeaveError.new(:a))
          executor.register(InterceptorsHelper::TestEnterLeaveError.new(:b))
          executor.register(InterceptorsHelper::TestEnterRaiseException.new(:c))

          executor.call

          expect(context[:a][:on_enter]).to eq 1
          expect(context[:a][:on_error]).to eq 1
          expect(context[:a]).not_to have_key(:on_leave)

          expect(context[:b][:on_enter]).to eq 1
          expect(context[:b][:on_error]).to eq 1
          expect(context[:b]).not_to have_key(:on_leave)

          expect(context[:error]).not_to be_nil

          expect(context.to_h).not_to have_key(:c)

          expect(context[:error]).not_to be_nil
        end

        it "calls on_error on the last interceptor if an error is raised" do
          executor.register(InterceptorsHelper::TestEnterLeaveError.new(:a))
          executor.register(InterceptorsHelper::TestEnterLeaveError.new(:b))
          executor.register(InterceptorsHelper::TestEnterErrorRaiseException.new(:c))
          context = executor.call

          expect(context[:a][:on_enter]).to eq 1
          expect(context[:a][:on_error]).to eq 1
          expect(context[:a]).not_to have_key(:on_leave)

          expect(context[:b][:on_enter]).to eq 1
          expect(context[:b][:on_error]).to eq 1
          expect(context[:b]).not_to have_key(:on_leave)

          expect(context[:c]).to eq({ on_error: 1 })

          expect(context[:error]).not_to be_nil
        end

        it "can resolve an error" do
          executor.register(InterceptorsHelper::TestEnterLeaveError.new(:a))
          executor.register(InterceptorsHelper::TestEnterLeaveErrorResolve.new(:b))
          executor.register(InterceptorsHelper::TestEnterErrorRaiseException.new(:c))

          context = executor.call

          expect(context[:a][:on_enter]).to eq 1
          expect(context[:a][:on_leave]).to eq 1
          expect(context[:a]).not_to have_key(:on_error)

          expect(context[:b][:on_enter]).to eq 1
          expect(context[:b][:on_error]).to eq 1
          expect(context[:b]).not_to have_key(:on_leave)

          expect(context[:c]).to eq({ on_error: 1 })

          expect(context[:error]).to be_nil
        end


        it 'on error is called when on leave is raising an error' do
          executor.register(InterceptorsHelper::TestEnterError.new(:a))
          executor.register(InterceptorsHelper::TestEnterLeaveRaiseError.new(:b))
          executor.register(InterceptorsHelper::TestEnterLeave.new(:c))

          executor.call

          expect(context[:a]).to eq({ on_enter: 1, on_error: 1 })
          expect(context[:b]).to eq({ on_enter: 1 })
          expect(context[:c]).to eq({ on_enter: 1, on_leave: 1 })

          expect(context[:error]).not_to be_nil
        end
      end
    end
  end
end
