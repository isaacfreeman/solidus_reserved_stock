module Spree

  class StockReserver
    def initialize(reserved_stock_location = nil)
      @reserved_stock_location = reserved_stock_location || Spree::StockLocation.reserved_items_location
    end

    # TODO: what if that quantity isn't available?
    # TODO: WHat if quantity is negative?
    # TODO: Use stock transfers.
    # TODO: Figure out how on earth stock transfers are supposed to work
    def reserve(variant, original_stock_location, user, quantity)
      # if quantity < 1 && !stock_item(variant)
      #   raise InvalidMovementError.new(Spree.t(:negative_movement_absent_item))
      # end
      user.reserved_stock_item_or_create(variant, original_stock_location)
        .stock_movements
        .create!(quantity: quantity)
      original_stock_location.unstock(variant, quantity)
    end

    def restock(variant, user, quantity=nil)
      # stock_item = @reserved_stock_location.stock_item(variant, user)
      # original_stock_location = stock_item.orginal_stock_location
      # quantity ||= stock_item.count_on_hand
      original_stock_location.move(variant, quantity, @reserved_stock_location)
    end

    def restock_expired
      @reserved_stock_location.stock_items.expired.each do |stock_item|
        restock(stock_item)
      end
    end

  end
end
