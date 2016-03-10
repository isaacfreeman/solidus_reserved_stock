module Spree
  module Admin
    StockItemsController.class_eval do
      helper Spree::Admin::ReservedStockItemsHelper
    end
  end
end
