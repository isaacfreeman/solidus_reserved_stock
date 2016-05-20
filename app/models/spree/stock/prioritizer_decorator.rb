Spree::Stock::Prioritizer.class_eval do
  private

  # Overridden to use reserved_stock_location first
  def sort_packages
    @packages = @packages
      .partition { |package| package.stock_location == reserved_stock_location }
      .flatten
  end

  def reserved_stock_location
    Spree::StockLocation.reserved_items_location
  end
end
