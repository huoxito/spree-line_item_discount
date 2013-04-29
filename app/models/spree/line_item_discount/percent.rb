module Spree
  module LineItemDiscount
    class Percent < Calculator
      preference :percent, :decimal, :default => 0
      attr_accessible :preferred_percent

      def self.description
        I18n.t(:percent_per_item)
      end

      def compute(item)
        ((item.price * item.quantity) * preferred_percent) / 100
      end
    end
  end
end
