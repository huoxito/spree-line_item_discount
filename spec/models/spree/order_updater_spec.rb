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

    context "eligible promo" do
      context "populate order with new variant" do
        before { order.contents.add(variant, 1) }

        it "applies existing line item discounts" do
          expect(order.total.to_f).to_not eql variant.price.to_f
        end
      end
    end

    context "promo not eligible when item is first created" do
      # Order total needs to be greater than 30
      let(:rule) { Promotion::Rules::ItemTotal.create(preferred_amount: 30, preferred_operator: "gt") }

      before do
        promotion.rules << rule
        expect(variant.price).to be < rule.preferred_amount
        order.contents.add(variant, 1)
      end

      it "doesn't apply existing discount to order total" do
        expect(order.total.to_f).to eql variant.price.to_f
      end

      context "promo becomes eligible" do
        before do
          order.contents.add(variant, 8)
        end

        it "applies existing discount to order total" do
          expect(order.total.to_f).to_not eql (variant.price * 9).to_f
        end
      end
    end
  end
end
