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
    end
  end
end
