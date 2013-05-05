module Spree
  module LineItemDiscount
    class Engine < Rails::Engine
      engine_name 'spree/line_item_discount'

      config.autoload_paths += %W(#{config.root}/lib)

      config.generators do |g|
        g.test_framework :rspec
      end

      initializer 'spree.promo.register.promotions.actions' do |app|
        app.config.spree.promotions.actions << Adjust
      end

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), "../../../app/**/*_decorator*.rb")) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end

      config.to_prepare &method(:activate).to_proc
    end
  end
end
