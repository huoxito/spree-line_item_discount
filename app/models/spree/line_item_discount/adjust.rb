module Spree
  module LineItemDiscount
    class Adjust < PromotionAction
      include Core::CalculatedAdjustments

      attr_reader :order, :line_items, :adjustable

      has_many :adjustments, :as => :originator

      before_validation :ensure_action_has_calculator

      # decide whether adjustment should be deleted or not
      before_destroy :deals_with_adjustments

      # TODO Since the action will be perfomed on the line item creation
      # it no longer needs to receive a items collection neither it needs
      # to receive a hash. Instead we can just pass the line_item object
      def perform(options = {})
        @order, @line_items = options[:order], options[:items] || []

        line_items.each do |item|
          unless has_applied?(item)
            amount = self.compute_amount(item)
            create_adjustment(amount: amount, adjustable: item, source: order)
          end
        end
      end

      # Receives an adjustable object (here a LineItem)
      def eligible?(adjustable)
        @adjustable, @order = adjustable, adjustable.order
        self.promotion.eligible?(order) && best_than_concurrent_discounts?
      end

      # Receives an adjustable object (here a LineItem)
      #
      # Returns total discount for the adjustable
      def compute_amount(adjustable)
        amount = self.calculator.compute(adjustable).to_f.abs
        [adjustable.total, amount].min * -1
      end

      private
        def has_applied?(item)
          self.adjustments.map(&:adjustable).flatten.include? item
        end

        def create_adjustment(params)
          self.adjustments.create(default_adjustment_params.merge(params), :without_protection => true)
        end

        def best_than_concurrent_discounts?
          return false if current_discount == 0
          if current_discount == best_concurrent_amount && best_concurrent_discount.eligible
            return false
          end

          current_discount <= best_concurrent_amount || !best_concurrent_discount.eligible
        end

        def current_adjustment
          @adjustment ||= self.adjustments.where("adjustable_id = ? AND adjustable_type = ?", adjustable.id, adjustable.class.name).first
        end

        def current_discount
          current_adjustment.amount
        end

        def best_concurrent_amount
          best_concurrent_discount ? best_concurrent_discount.amount : 0
        end

        def best_concurrent_discount
          adjustable.adjustments.promotion.eligible
            .where('id NOT IN (?)', [current_adjustment]).max { |a,b| a.amount.abs <=> b.amount.abs }
        end

        def default_adjustment_params
          { :label => self.promotion.name, :mandatory => false }
        end

        def ensure_action_has_calculator
          self.calculator = Percent.new unless self.calculator
        end

        def deals_with_adjustments
          self.adjustments.each do |adjustment|
            if adjustment.adjustable.complete?
              adjustment.originator = nil
              adjustment.save
            else
              adjustment.destroy
            end
          end
        end
    end
  end
end
