require 'spec_helper'

module Spree
  module LineItemDiscount
    describe PromotionPool do
      let(:order) { create(:order) }
      let(:variant) { create(:variant) }

      let(:rule) { Promotion::Rules::ItemTotal.create(preferred_amount: 30, preferred_operator: "gt") }
      let(:calculator) { LineItemDiscount::Percent.create(preferred_percent: 10) }
      let(:action) { LineItemDiscount::Adjust.new }
      let(:promotion) { create(:promotion) }

      before do
        promotion.actions << action
        action.calculator = calculator
        action.save!

        promotion.rules << rule
      end

      subject { PromotionPool.new(order) }

      context "existing promo is not eligible" do
        before { order.contents.add(variant, 1) }

        it { expect(subject.eligible).to be_empty }

        it "doesn't return adjustments from that promo" do
          expect(subject.valid_discounts.map(&:originator)).to eq []
        end

        context "promo becomes eligible" do
          let!(:previous_adjustment) { order.line_items.first.adjustments.first }

          before { order.contents.add(variant, 8) }

          it "adjust existing adjustments values" do
            subject.adjust!
            expect(subject.valid_discounts.map(&:amount)).to_not eq [previous_adjustment.amount]
          end
        end
      end

      context "existing promo is eligible" do
        before { order.contents.add(variant, 8) }

        it "returns array of eligible actions" do
          expect(subject.eligible).to eq [action]
        end

        it "returns adjustments from that promo" do
          expect(subject.valid_discounts.map(&:originator)).to eq [action]
        end
      end
    end
  end
end
