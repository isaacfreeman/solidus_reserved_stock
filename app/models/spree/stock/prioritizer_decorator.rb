Spree::Stock::Prioritizer.class_eval do
  private

  # Use reserved_stock_location first
  alias_method :original_sort_packages, :sort_packages
  def sort_packages
    original_sort_packages

    reserved_stock_location = Spree::StockLocation.reserved_items_location
    @packages = @packages
                .partition do |package|
                  package.stock_location == reserved_stock_location
                end
                .flatten
  end
end
