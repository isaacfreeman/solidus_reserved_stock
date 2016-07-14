module Spree
  module Stock
    # Reserve and restock variants
    class Reserver
      class InvalidQuantityError < StandardError; end

      def initialize(variant = nil, user = nil, original_stock_location = nil, reserved_stock_location = nil)
        @variant = variant
        @user = user
        @original_stock_location = original_stock_location
        reserved_stock_location ||= Spree::StockLocation.reserved_items_location
        @reserved_stock_location = reserved_stock_location
      end

      # TODO: Use stock transfers.
      # TODO: Make stock_location optional, and if not present use whatever's
      #       available
      # TODO: Raise suitable error if variant is nil (otherwise we get
      #       InvalidQuantityError)
      def reserve(quantity, expires_at = nil)
        if quantity < 1 || quantity.blank?
          raise InvalidQuantityError, Spree.t(:quantity_must_be_positive)
        end
        if quantity > @original_stock_location.count_on_hand(@variant)
          raise InvalidQuantityError, Spree.t(:insufficient_stock_available)
        end
        reserved_stock_item = @user.reserved_stock_item_or_create(
          @variant,
          @original_stock_location,
          expires_at
        )
        reserved_stock_item.stock_movements.create!(quantity: quantity)
        @original_stock_location.unstock(@variant, quantity)
        reserved_stock_item
      end

      # TODO: Use stock transfers
      # TODO: Add locale files
      def restock(quantity = nil)
        reserved_stock_item = @user.reserved_stock_item(
          @variant,
          @original_stock_location
        )
        raise(
          InvalidQuantityError,
          Spree.t(:no_stock_reserved_for_user_and_variant)
        ) unless reserved_stock_item.present?
        reserved_count_on_hand = reserved_stock_item.count_on_hand
        if quantity.present?
          if quantity < 1
            raise InvalidQuantityError,
                  Spree.t(:quantity_must_be_positive)
          end
          if quantity > reserved_count_on_hand
            raise InvalidQuantityError,
                  Spree.t(:insufficient_reserved_stock_available)
          end
        end
        quantity ||= reserved_count_on_hand
        perform_restock(reserved_stock_item, quantity)
      end

      def restock_expired
        @reserved_stock_location.expired_stock_items.each do |expired_item|
          perform_restock(expired_item)
        end
      end

      private

      def perform_restock(reserved_stock_item, quantity = nil)
        quantity ||= reserved_stock_item.count_on_hand
        variant = reserved_stock_item.variant
        user = reserved_stock_item.user
        original_stock_location = reserved_stock_item.original_stock_location
        @reserved_stock_location.unstock(variant, quantity, nil, user, original_stock_location)
        original_stock_location.move(variant, quantity)
        reserved_stock_item.reload
        reserved_stock_item.destroy if reserved_stock_item.count_on_hand == 0
        reserved_stock_item
      end
    end
  end
end
