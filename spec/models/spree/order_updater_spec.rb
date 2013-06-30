require 'spec_helper'

module Spree
  describe OrderUpdater do
    let(:order) { create(:order) }
    let(:variant) { create(:variant) }

    let(:calculator) { LineItemDiscount::Percent.create(preferred_percent: 10) }
    let(:action) { LineItemDiscount::Adjust.new }
    let(:promotion) { create(:promotion) }

    before do
      promotion.actions << action
      action.calculator = calculator
      action.save!
    end

    context "populate order with new variant" do
      before { order.contents.add(variant, 1) }

      it "applies existing line item discounts" do
        expect(order.total.to_f).to_not eql variant.price.to_f
      end
    end
  end
end
