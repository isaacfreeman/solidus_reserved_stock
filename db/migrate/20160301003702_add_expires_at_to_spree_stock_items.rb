class AddExpiresAtToSpreeStockItems < ActiveRecord::Migration
  def change
    add_column :spree_stock_items, :expires_at, :datetime
  end
end
