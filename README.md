# SolidusReservedStock

Allow stock to be reserved for a given user, so it can't be purchased by other users.

When a customer reserves stock, it's moved from its normal stock location to a special reserved stock location. When a customer checks out, their reserved items will be used first to fulfill their order.

Reserved stock can be restored to its original stock location at any time, and can be stored with an expiry date for the reservation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'solidus_reserved_stock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install solidus_reserved_stock

## Usage

<!-- TODO: Write usage instructions here -->

### API Usage
<!-- TODO: Document API request here, and point to Swagger documentation -->
- reserve
- restock
- restock_expired

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/resolve/solidus_reserved_stock. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
