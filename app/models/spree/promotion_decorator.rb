module Spree
  Promotion.class_eval do
    def product_ids
      product_scope = rules.includes(:products).where("spree_promotion_rules.type = 'Spree::Promotion::Rules::Product'")
      product_scope.map(&:product_ids).flatten
    end
  end
end
