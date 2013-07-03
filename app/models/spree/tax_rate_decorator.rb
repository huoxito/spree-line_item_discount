module Spree
  TaxRate.class_eval do
    def self.adjust(order)
      order.adjustments.tax.destroy_all
      order.line_item_adjustments.where(originator_type: 'Spree::TaxRate').destroy_all

      self.match(order).each do |rate|
        rate.adjust(order)
      end
    end
  end
end
