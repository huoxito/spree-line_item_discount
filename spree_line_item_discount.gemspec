# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree/line_item_discount/version'

Gem::Specification.new do |gem|
  gem.name          = "spree-line_item_discount"
  gem.version       = Spree::LineItemDiscount::VERSION
  gem.authors       = ["Washington Luiz"]
  gem.email         = ["huoxito@gmail.com"]
  gem.description   = "Apply promotion adjustments per items"
  gem.summary       = "Apply promotion adjustments per items"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'spree_core', '~> 2.0'

  gem.add_development_dependency 'factory_girl', '~> 4.2'
  gem.add_development_dependency 'rspec-rails',  '~> 2.13'
  gem.add_development_dependency 'sqlite3'
end
