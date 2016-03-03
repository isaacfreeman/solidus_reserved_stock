module Spree

  class StockReserver
    def initialize(reserved_stock_location = nil)
      @reserved_stock_location = reserved_stock_location || Spree::StockLocation.reserved_items_location
    end

    # TODO: what if that quantity isn't available?
    # TODO: WHat if quantity is negative?
    # TODO: Use stock transfers.
    # TODO: Figure out how on earth stock transfers are supposed to work
    def reserve(variant, original_stock_location, user, quantity, expires_at=nil)
      # if quantity < 1 && !stock_item(variant)
      #   raise InvalidMovementError.new(Spree.t(:negative_movement_absent_item))
      # end
      reserved_stock_item = user.reserved_stock_item_or_create(variant, original_stock_location, expires_at)
      reserved_stock_item.stock_movements.create!(quantity: quantity)
      original_stock_location.unstock(variant, quantity)
      reserved_stock_item
    end

    # TODO: Use stock transfers
    def restock(variant, user, quantity=nil)
      reserved_stock_item = user.reserved_stock_item(variant)
      quantity ||= reserved_stock_item.count_on_hand
      @reserved_stock_location.unstock(variant, quantity)
      reserved_stock_item.original_stock_location.move(variant, quantity)
      reserved_stock_item.reload
    end

    # TODO: This inefficiently requires restock to find the stock item again
    def restock_expired
      @reserved_stock_location.expired_stock_items.each do |reserved_stock_item|
        variant = reserved_stock_item.variant
        quantity = reserved_stock_item.count_on_hand
        @reserved_stock_location.unstock(variant, quantity)
        reserved_stock_item.original_stock_location.move(variant, quantity)
      end
    end
  end
end
