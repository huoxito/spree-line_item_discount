module Spree
  Order.class_eval do
    has_many :line_item_adjustments, through: :line_items, source: :adjustments
  end
end
