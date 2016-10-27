module UseReservedStockLocationFirst
  private

  def sort_packages
    super
    reserved_stock_location = Spree::StockLocation.reserved_items_location
    @packages = @packages.
                partition do |package|
                  package.stock_location == reserved_stock_location
                end.
                flatten
  end
end
Spree::Stock::Prioritizer.prepend UseReservedStockLocationFirst
