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
Access to stock reservations is currently provided only through an API, and back end admin controls. Helper methods for the front end are a possibility for the future if there's enough interest.

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

### Back End
On the Solidus back end, `solidus_reserved_stock` adds a new `Reserved Items` sidebar menu item to user edit pages. Admins can use this to reserve stock for a customer or restock reserved items. An expiry date is optional.

The Reserved Items stock location appears in Settings, like all stock locations.

## How it works
The site maintains a special stock location that accepts ReservedStockItems – a subclass of Spree::StockItem with some additional features. ReservedStockItems remember their original stock location and the user they were reserved for, with validation relaxed so that different users may have reservations for the same variant.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/resolve/solidus_reserved_stock. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## Future Plans
- Currently the gem is designed mainly for use via the API. I'd like to build out some helper methods to support using it from the Solidus front end.
- Further overrides are needed to various Solidus methods that deal with stock levels. In general, they should include reserved items if a user argument is provided. See e.g. app/models/spree/variant_decorator.rb
- Currently there's a single reserved stock location for all reserved stock items. There's been some interest in allowing an arbitrary number of reserved stock locations.
- Currently we require a source stock location to be specified for each reservation. It would be nice to make this optional, and if not present draw from whichever stock locations have stock in the given variant, according to normal Solidus prioritization.
- Reserving stock should use stock transfers, but currently doesn't.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
