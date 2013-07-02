# SpreeLineItemDiscounts

Trying to get an idea on what the extension should do and how it should do it
-----------------------------------------------------------------------------

* Apply promo adjustments at the LineItem level on a Spree ~> 2.0 install

* Item Discount promos don't require `event_name` they should be set to nil

* Item Discount promos should only have one single action

* Adjustments should be inserted at the line item creation before the order
  receive `update!`. Hopefully that will give room to make order changes way more
  perfomant

* The same promo may apply adjustments to multiple line items on the order

* Multiple adjustments from different promos may be applied to the same line item

* The same adjustment cannot apply twice on the same item

## Installation

Add to your Gemfile

```ruby
gem 'spree-line_item_discount', github: 'huoxito/spree-line_item_discount'
```

## Usage

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
