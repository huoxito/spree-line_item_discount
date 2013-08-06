require 'spec_helper'

module Spree
  describe Order do
    let(:line_item) { create(:line_item) }
    let(:order) { line_item.order }

    let(:promotion) { create(:promotion) }
    let(:calculator) { LineItemDiscount::Percent.create(preferred_percent: 10) }
    let(:action) { LineItemDiscount::Adjust.create({promotion: promotion, calculator: calculator}, without_protection: true) }

    context "finalize" do
      before { action.perform(line_item) }

      it "locks line item adjustments" do
        order.finalize!
        expect(order.line_item_adjustments.first).to be_closed
      end
    end
  end
end
