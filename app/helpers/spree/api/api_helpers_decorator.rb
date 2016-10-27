module IncludeReservedItemsInStockLocationAttributes
  def stock_location_attributes
    super | [:reserved_items]
  end
end
Spree::Api::ApiHelpers.prepend IncludeReservedItemsInStockLocationAttributes
