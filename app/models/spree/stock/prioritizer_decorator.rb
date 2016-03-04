Spree::Stock::Prioritizer.class_eval do
  def sort_packages
    @packages = @packages
      .partition { |package| package.stock_location == reserved_stock_location }
      .flatten
  end

  private

  def reserved_stock_location
    Spree::StockLocation.reserved_items_location
  end
end
