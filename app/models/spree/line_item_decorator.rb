module Spree
  LineItem.class_eval do
    # Trigger LineItemDiscount promos
    #
    # It makes more sense to run it here because the order did not receive
    # +update!+ just yet. If it complied with the usual Spree AS::Notifications
    # events promo triggers we would have to run +update!+ on the order for each
    # promo which is not perfomant at all
    after_create :activate_discounts

    private
      def activate_discounts
        unless order.completed?
          LineItemDiscount::Adjust.includes(:promotion).all.each do |adjust_discount|
            promotion = adjust_discount.promotion
            if promotion.product_ids.empty? || promotion.product_ids.include?(self.product.id)
              adjust_discount.perform(self)
            end
          end
        end
      end
  end
end
