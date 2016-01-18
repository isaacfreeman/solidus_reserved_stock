module Spree

  class StockReserver
    def initialize(reserved_stock_location = nil)
      @reserved_stock_location = reserved_stock_location || Spree::StockLocation.reserved_items_location
    end

    # TODO: Should we give this a stock_item or a variant?
    # TODO: what if that quantity isn't available?
    def reserve(variant, original_stock_location, user, quantity)
      @reserved_stock_location.move(variant, quantity, user)
      original_stock_location.unstock(variant, quantity, user)
    end

    def restock(stock_item)
      stock_item.stock_location.move(stock_item.variant, quantity, @reserved_stock_location)
    end

    def restock_expired
      @reserved_stock_location.stock_items.expired.each do |stock_item|
        restock(stock_item)
      end
    end

  end
end
