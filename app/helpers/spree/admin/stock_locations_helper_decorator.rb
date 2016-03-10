module Spree
  module Admin
    module StockLocationsHelper

      alias_method :original_display_name, :display_name
      def display_name(stock_location)
        name = original_display_name(stock_location)
        return name unless stock_location.reserved_items?
        "#{name} (Reserved Items)"
      end

    end
  end
end
