# Append "(Reserved Items)"" after stock location display name 
module IndicateReservedItemsInStockLocationDisplayName
  def admin_stock_location_display_name(stock_location)
    display_name = super
    return display_name unless stock_location.reserved_items?
    "#{display_name} (Reserved Items)"
  end
end
Spree::Admin::StockLocationsHelper.prepend IndicateReservedItemsInStockLocationDisplayName
