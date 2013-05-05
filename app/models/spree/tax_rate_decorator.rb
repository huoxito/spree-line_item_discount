module Spree
  TaxRate.class_eval do
    def self.adjust(order)
      order.adjustments.tax.each(&:destroy)
      order.line_items.each do |item|
        item.adjustments.tax.each(&:destroy)
      end

      self.match(order).each do |rate|
        rate.adjust(order)
      end
    end
  end
end
