class AddUserIdToSpreeStockItems < ActiveRecord::Migration
  def change
    add_column :spree_stock_items, :user_id, :association
  end
end
