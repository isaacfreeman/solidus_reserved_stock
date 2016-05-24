module Spree
  module Stock
    class Reserver
      class InvalidQuantityError < StandardError; end

      def initialize(reserved_stock_location = nil)
        @reserved_stock_location = reserved_stock_location || Spree::StockLocation.reserved_items_location
      end

      # TODO: Use stock transfers.
      # TODO: Figure out how on earth stock transfers are supposed to work
      # TODO: Make stock_location optional, and if not present use stock_locations as for add-to-cart
      def reserve(variant, original_stock_location, user, quantity, expires_at=nil)
        if quantity < 1
          raise InvalidQuantityError.new(Spree.t(:quantity_must_be_positive))
        end
        if quantity > original_stock_location.count_on_hand(variant)
          raise InvalidQuantityError.new(Spree.t(:insufficient_stock_available))
        end
        reserved_stock_item = user.reserved_stock_item_or_create(variant, original_stock_location, expires_at)
        reserved_stock_item.stock_movements.create!(quantity: quantity)
        original_stock_location.unstock(variant, quantity)
        reserved_stock_item
      end

      # TODO: Use stock transfers
      # TODO: Add locale files
      def restock(variant, user, quantity=nil)
        reserved_stock_item = user.reserved_stock_item(variant)
        raise InvalidQuantityError.new(Spree.t(:no_stock_reserved_for_variant)) unless reserved_stock_item.present?
        if quantity
          if quantity < 1
            raise InvalidQuantityError.new(Spree.t(:quantity_must_be_positive))
          end
          if quantity > reserved_stock_item.count_on_hand
            raise InvalidQuantityError.new(Spree.t(:insufficient_reserved_stock_available))
          end
        end
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
end
