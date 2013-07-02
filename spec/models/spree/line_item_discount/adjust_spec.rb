require 'spec_helper'

module Spree
  module LineItemDiscount
    describe Adjust do
      let(:order) { create(:order) }
      let(:promotion) { create(:promotion) }
      let(:action) { Adjust.new }
      let!(:line_item) { create(:line_item, :order => order) }

      before { action.stub(:promotion => promotion) }

      context "#perform" do
        before { promotion.promotion_actions = [action] }

        it "computes amount before creating adjustment" do
          action.should_receive(:compute_amount).with(line_item).ordered
          action.should_receive(:create_adjustment).ordered
          action.perform(line_item)
        end

        it "creates adjustment with item as adjustable" do
          action.perform(line_item)
          line_item.adjustments.should == action.adjustments
        end

        it "creates adjustment with order as source" do
          action.perform(line_item)
          expect(line_item.adjustments.first.source).to eq order
        end

        it "does not perform twice on the same item" do
          2.times { action.perform(line_item) }
          action.adjustments.count.should == 1
        end
      end

      context "#eligible" do
        context "promotion is not eligible" do
          before { promotion.stub(eligible?: false) }
          it { action.should_not be_eligible(line_item) }
        end

        context "has a concurrent discount" do
          let(:adjustment) { mock_model(Spree::Adjustment, :amount => -100, :adjustable => line_item) }
          let(:concurrent) { mock_model(Spree::Adjustment, :amount => -100, :adjustable => line_item) }

          before(:each) do
            action.should_receive(:current_adjustment).at_least(:once).and_return(adjustment)
            action.should_receive(:best_concurrent_discount).at_least(:once).and_return(concurrent)
          end

          context "with same amount" do
            context "but not eligible" do
              before { concurrent.stub(:eligible => false) }
              specify { action.should be_eligible(line_item) }
            end

            context "and eligible" do
              before { concurrent.stub(:eligible => true) }
              specify { action.should_not be_eligible(line_item) }
            end
          end

          context "which is better" do
            before { concurrent.stub(:amount => -200) }

            context "but not eligible" do
              before { concurrent.stub(:eligible => false) }
              it { expect(action).to be_eligible(line_item) }
            end

            context "and eligible" do
              before { concurrent.stub(:eligible => true) }
              it { expect(action).to_not be_eligible(line_item) }
            end
          end

          context "which is worse" do
            before { concurrent.stub(:amount => -20) }
            it { expect(action).to be_eligible(line_item) }
          end
        end
      end

      context "#compute_amount" do
        before { promotion.promotion_actions = [action] }

        it "calls compute on the calculator" do
          action.calculator.should_receive(:compute).with(line_item)
          action.compute_amount(line_item)
        end

        context "calculator returns amount greater than item total" do
          before do
            action.calculator.should_receive(:compute).with(line_item).and_return(300)
            line_item.stub(total: 100)
          end

          it "does not exceed it" do
            action.compute_amount(line_item).should eql(-100)
          end
        end
      end
    end
  end
end
