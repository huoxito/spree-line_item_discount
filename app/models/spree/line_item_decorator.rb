module Spree
  LineItem.class_eval do
    # Trigger LineItemDiscount promos
    #
    # It makes more sense to run it here because the order did not receive
    # +update!+ just yet. If it complied with the usual Spree AS::Notifications
    # events promo triggers we would have to run +update!+ on the order for each
    # promo which is not perfomant at all
    after_create :perform_promo_discounts

    private
      def perform_promo_discounts
        LineItemDiscount::Adjust.all.each do |adjust_discount|
          adjust_discount.perform(self)
        end
      end
  end
end
