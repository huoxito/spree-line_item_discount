module Spree
  module LineItemDiscount
    # Compute adjustment amount and set their eligibility for all eligible promos
    #
    # The reason for doing it in a different class is that we only check the
    # promotion eligibility once. It also should make it pretty easy to manage
    # which adjustments should actually be computed. It doesn't make sense
    # to compute values for adjustments that are not eligible. As the extension
    # allows multiple adjustments for the same line item.
    #
    # ps. watch out for scenarios where the promo eligibilty changes as adjustments
    # are applied to the order total. Hopefully such cases don't exist and if
    # they do we might just consider that adjustments or any probably other
    # promotion action should not change the order eligibility among existing
    # promotions
    class PromotionPool
      attr_reader :actions, :order

      def initialize(order)
        @order = order
        @actions = Adjust.includes(:promotion).all
      end

      # Returns array of all eligible actions for the current order
      def eligible
        actions.select { |action| action.promotion.eligible? order }
      end

      # Returns array of all line item adjustments eligible for current order
      def valid_discounts
        adjustments(eligible.map(&:id))
      end

      def invalid_discounts
        adjustments(not_eligible.map(&:id))
      end

      def not_eligible
        actions.select { |action| !action.promotion.eligible? order }
      end

      # Update adjustment amounts for eligible actions
      #
      # Use +update_adjustment+ as it will not run any callbacks making
      def adjust!
        valid_discounts.each do |adjustment|
          adjustment.originator.update_adjustment(adjustment, adjustment.adjustable)
        end

        valid_discounts.update_all(eligible: true)
        invalid_discounts.update_all(eligible: false)
      end

      private
        def adjustments(originator_ids)
          Adjustment.promotion.source_order.includes(:originator)
            .where(originator_id: originator_ids, source_id: order.id)
        end
    end
  end
end
