# We need to be able to reserve the same variant for more than one user.
# This relaxes the uniqueness constraint introduced in Solidus 1.2 for
# supporting databases.
class ModifyStockItemUniqueIndex < ActiveRecord::Migration
  def change
    return unless connection.adapter_name =~ /postgres|sqlite/i
    remove_index "spree_stock_items", ["variant_id", "stock_location_id"]
    add_index "spree_stock_items",
              ["variant_id", "stock_location_id", "user_id"],
              where: "deleted_at is null",
              unique: true,
              name: "index_spree_stock_items_on_variant_stock_location_and_user"
  end
end
