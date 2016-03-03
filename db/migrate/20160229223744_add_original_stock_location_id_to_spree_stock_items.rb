class AddOriginalStockLocationIdToSpreeStockItems < ActiveRecord::Migration
  def change
    add_reference :spree_stock_items, :original_stock_location, index: true
  end
end
