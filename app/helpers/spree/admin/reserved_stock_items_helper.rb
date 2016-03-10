module Spree
  module Admin
    module ReservedStockItemsHelper
      def stock_location_name(stock_item)
        stock_location = stock_item.stock_location
        return stock_location.name unless stock_location.reserved_items?

        user_link = link_to(stock_item.user.email, admin_user_path(stock_item.user))
        "#{stock_location.name} (#{user_link})".html_safe
      end
    end
  end
end
