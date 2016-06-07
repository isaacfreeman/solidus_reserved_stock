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
`GET    /api/v1/reserved_stock_items.json`
Retrieve all reserved stock items

`GET    /api/v1/user/:user_id/reserved_stock_items.json`
Retrieve reserved stock items for a given user

`POST   /api/v1/reserved_stock_items/reserve.json`
Reserve stock for a given user.
Parameters:
- `variant_id` or `sku` to identify the variant (one of these is required)
- `original_stock_location_id` to remove stock from (required)
- `user_id` identifying the user the stock will be reserved for (required)
- `quantity` of stock to reserve (required)
- `expires_at` date when the reservation ends and stock can be returned to the original stock location (optional)

`POST   /api/v1/reserved_stock_items/restock.json`
Return reserved stock to its original stock location.
Parameters:
- `variant_id` or `sku` to identify the variant (one of these is required)
- `user_id` identifying the user the stock was be reserved for (required)
- `quantity` of stock to restore (optional – if not present, the full amount of reserved stock will be restored)

`POST   /api/v1/reserved_stock_items/restock_expired.json`
Restock all reserved items whose expiry date has passed.

`GET    /api/stock_locations(.:format)`
This is the same as the standard Solidus route, but the response is decorated to include a `reserved_items` parameter indicating whether the stock location is for reserved stock items.

`GET    /api/variants/:id?user_id=:user_id`
`GET    /api/products/:id?user_id=:user_id`
Same as the standard Solidus routes, but accept an optional `user_id` parameter
so that `total_on_hand` can include reserved stock for the user.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/resolve/solidus_reserved_stock. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
