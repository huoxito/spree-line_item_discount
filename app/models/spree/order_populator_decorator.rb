module Spree
  OrderPopulator.class_eval do
    attr_reader :items

    def initialize(order, currency)
      @order = order
      @items = []
      @currency = currency
      @errors = ActiveModel::Errors.new(self)
    end

    private
      def attempt_cart_add(variant_id, quantity)
        quantity = quantity.to_i
        if quantity > 2_147_483_647
          errors.add(:base, I18n.t(:please_enter_reasonable_quantity, :scope => :order_populator))
          return false
        end

        variant = Spree::Variant.find(variant_id)
        if quantity > 0
          if check_stock_levels(variant, quantity)
            items.push @order.contents.add(variant, quantity, currency)
          end
        end
      end
  end
end
