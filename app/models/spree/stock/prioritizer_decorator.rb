Spree::Stock::Prioritizer.class_eval do
  private

  # Overridden to use reserved_stock_location first
  def sort_packages
    reserved_stock_location = Spree::StockLocation.reserved_items_location
    @packages = @packages
                .partition do |package|
                  package.stock_location == reserved_stock_location
                end
                .flatten
  end
end
