# Designate a stock location as being for reserved stock items
class AddReservedItemsToStockLocation < ActiveRecord::Migration
  def change
    add_column :spree_stock_locations, :reserved_items, :boolean, default: false
  end
end
