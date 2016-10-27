class AllowMultipleReservedStockItemsWithDifferentOriginalStockLocation < ActiveRecord::Migration
  def change
    return unless connection.adapter_name =~ /postgres|sqlite/i
    remove_index "spree_stock_items", name: "index_spree_stock_items_on_variant_stock_location_and_user"
    add_index "spree_stock_items",
              ["variant_id", "stock_location_id", "user_id", "original_stock_location_id"],
              where: "deleted_at is null",
              unique: true,
              name: "index_spree_stock_items_on_variant_sl_user_and_osl"
  end
end
