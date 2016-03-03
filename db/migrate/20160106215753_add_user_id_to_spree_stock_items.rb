class AddUserIdToSpreeStockItems < ActiveRecord::Migration
  def change
    add_reference :spree_stock_items, :user, index: true
  end
end
