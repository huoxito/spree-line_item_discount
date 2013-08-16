require 'spec_helper'

module Spree
  describe LineItem do
    let(:variant) { create(:variant) }
    let(:order) { Order.create }

    context "completed order" do
      before { Order.any_instance.stub completed?: true }

      it "doesnt activate discounts" do
        pending "implement something like LineItemDiscount::Adjust.activate"
        expect(LineItemDiscount::Adjust).not_to receive(:all)
        order.contents.add(variant, 1)
      end
    end

    context "applying promos" do
      let(:order) { Order.create }
      let(:variant) { create(:variant) }

      let(:calculator) { LineItemDiscount::Percent.create(preferred_percent: 10) }
      let(:action) { LineItemDiscount::Adjust.new }
      let(:promotion) { create(:promotion) }

      before do
        promotion.actions << action
        action.calculator = calculator
        action.save!
      end

      context "promotion requires specific item to be eligible" do
        let(:product_rule) { Promotion::Rules::Product.create }
        let(:bag) { variant.product }
        let(:tshirt) { create(:product) }

        before do
          product_rule.products << bag
          promotion.rules << product_rule
        end

        it "doesnt create adjustments for items not eligible" do
          order.contents.add(tshirt.master, 1)
          expect(order.line_item_adjustments).to be_empty
        end

        it "create adjustments for items eligible" do
          order.contents.add(bag.master, 1)
          expect(order.line_item_adjustments).not_to be_empty
        end
      end
    end
  end
end
