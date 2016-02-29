class AddOriginalStockLocationIdToSpreeStockItems < ActiveRecord::Migration
  def change
    add_column :spree_stock_items, :original_stock_location_id, :association
  end
end
