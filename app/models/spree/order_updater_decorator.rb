module Spree
  OrderUpdater.class_eval do
    # Overriden from Spree core
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

    def items_adjustments_total
      line_item_adjustments.map(&:amount).sum
    end

    def line_item_adjustments
      line_items.inject([]) do |discounts, line_item|
        discounts.concat line_item.adjustments.eligible
      end
    end
  end
end
