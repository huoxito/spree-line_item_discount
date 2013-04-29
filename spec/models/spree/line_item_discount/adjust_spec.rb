require 'spec_helper'

module Spree
  module LineItemDiscount
    describe Adjust do
      let(:order) { create(:order) }
      let(:promotion) { create(:promotion) }
      let(:action) { Adjust.new }

      context "#perform" do
        let!(:line_item) { create(:line_item, :order => order) }

        before(:each) do
          promotion.promotion_actions = [action]
          action.stub(:promotion => promotion)
        end

        it "computes amount before creating adjustment" do
          action.should_receive(:compute_amount).ordered
          action.should_receive(:create_adjustment).ordered
          action.perform(:order => order, :items => [line_item])
        end

        it "creates adjustment with item as adjustable" do
          action.perform(:order => order, :items => [line_item])
          line_item.adjustments.should == action.adjustments
        end

        it "does not perform twice" do
          2.times { action.perform(:order => order, :items => [line_item]) }
          action.adjustments.count.should == 1
        end
      end
    end
  end
end
