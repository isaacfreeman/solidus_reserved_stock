# Class methods to handle stock locations that contain reserved items
# Typically I'd expect there to be only one stock location for reserved items,
# but at this stage we're not enforcing that.
# TODO: Move these methods to a concern with a nice clear name

Spree::StockLocation.class_eval do
  scope :reserved_items, -> { where(reserved_items: true) }

  def self.reserved_items_location
    return reserved_items.first if reserved_items.any?
    Spree::StockLocation.create(
      name: "Reserved Items",
      reserved_items: true,
      propagate_all_variants: false
    )
  end
end
