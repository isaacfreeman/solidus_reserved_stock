# Class methods to handle stock locations that contain reserved items
# Typically I'd expect there to be only one stock location for reserved items,
# but at this stage we're not enforcing that.
# TODO: Move these methods to a concern with a nice clear name
module Spree
  StockLocation.class_eval do
    scope :reserved_items, -> { where(reserved_items: true) }

    def self.reserved_items_location
      return reserved_items.first if reserved_items.any?
      Spree::StockLocation.create(
        name: "Reserved Items",
        reserved_items: true,
        propagate_all_variants: false
      )
    end

    def expired_stock_items
      reserved_stock_items.where("expires_at < ?", Time.zone.now)
    end

    def reserved_stock_items
      stock_items.where(type: Spree::ReservedStockItem)
    end
  end
end
