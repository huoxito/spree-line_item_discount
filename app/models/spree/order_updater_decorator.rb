module Spree
  OrderUpdater.class_eval do
    # Overriden from Spree core
    # So that it sums line_items_adjustments total to order.adjustment_total
    #
    # Updates the following Order total values:
    #
    # +payment_total+      The total value of all finalized Payments (NOTE: non-finalized Payments are excluded)
    # +item_total+         The total value of all LineItems
    # +adjustment_total+   The total value of all adjustments (promotions, credits, etc.)
    # +total+              The so-called "order total."  This is equivalent to +item_total+ plus +adjustment_total+.
    def update_totals
      order.payment_total = payments.completed.map(&:amount).sum
      order.item_total = line_items.map(&:amount).sum
      order.adjustment_total = adjustments.eligible.map(&:amount).sum + items_adjustments_total
      order.total = order.item_total + order.adjustment_total
    end

    # Overriden from Spree core
    # As of LineItemDiscount it updates adjustments value and eligibility
    #
    # Updates each of the Order adjustments.
    #
    # This is intended to be called from an Observer so that the Order can
    # respond to external changes to LineItem, Shipment, other Adjustments, etc.
    #
    # Adjustments will check if they are still eligible. Ineligible adjustments
    # are preserved but not counted towards adjustment_total.
    def update_adjustments
      order.adjustments.reload.each { |adjustment| adjustment.update! }
      choose_best_promotion_adjustment
      LineItemDiscount::PromotionPool.new(order).adjust!
    end

    private
      def items_adjustments_total
        order.line_item_adjustments.eligible.sum(&:amount)
      end
  end
end
