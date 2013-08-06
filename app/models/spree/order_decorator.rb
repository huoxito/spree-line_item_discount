module Spree
  Order.class_eval do
    has_many :line_item_adjustments, through: :line_items, source: :adjustments

    # Overriden from spree core
    # So that we can also lock line_item adjustments
    #
    # TODO Refactoring spree core by adding an Order `finalize_hooks` method
    # similar to what we currently have in OrderUpdater. That gives room
    # to implement custom logic without having to override the +finalize!+ method
    #
    # Finalizes an in progress order after checkout is complete.
    # Called after transition to complete state when payments will have been processed
    def finalize!
      touch :completed_at

      # lock all adjustments (coupon promotions, etc.)
      adjustments.update_all "state = 'closed'"

      # As of Spree::LineItemDiscount
      line_item_adjustments.update_all "state = 'closed'"

      # update payment and shipment(s) states, and save
      updater.update_payment_state
      shipments.each do |shipment|
        shipment.update!(self)
        shipment.finalize!
      end

      updater.update_shipment_state
      save
      updater.run_hooks

      deliver_order_confirmation_email

      self.state_changes.create({
        previous_state: 'cart',
        next_state:     'complete',
        name:           'order' ,
        user_id:        self.user_id
      }, without_protection: true)
    end
  end
end
