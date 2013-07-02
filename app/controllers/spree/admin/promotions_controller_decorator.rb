module Spree
  module Admin
    PromotionsController.class_eval do
      protected
        # Overriden from Spree core
        #
        # Give frontend users a chance to ignore event_name as promos by the
        # extension should have event_name set to nil
        def load_event_names
          @event_names = Spree::Activator.event_names.map { |name| [Spree.t("events.#{name}"), name] }
          @event_names.unshift []
        end
    end
  end
end
