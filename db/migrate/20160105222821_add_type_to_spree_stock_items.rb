# Enable singel-table inheritance for stock items, so we can store
# ReservedStockItems
class AddTypeToSpreeStockItems < ActiveRecord::Migration
  def change
    add_column :spree_stock_items, :type, :string
  end
end
