module Spree
  Adjustment.class_eval do
    scope :source_order, -> { where(source_type: "Spree::Order") }

    # Overriden from Spree core
    #
    # Allow originator of the adjustment to perform an additional eligibility of the adjustment
    # Should return _true_ if originator is absent or doesn't implement _eligible?_
    #
    # Pass the +adjustable+ object instead of the +source+ to +eligible?+ to allow
    # the extension to check concurrent discounts for a line item. This shouldn't
    # make any difference on the original mtehod for spree_core beacuse there
    # both +adjustable+ and +source+ is the same Order object
    #
    # FIXME maybe we don't need to care about concurrent line item adjustments
    # right now so passing just the order should be fine
    def eligible_for_originator?
      return true if originator.nil?
      !originator.respond_to?(:eligible?) || originator.eligible?(adjustable)
    end
  end
end
