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
  end
end
