Spree.user_class.class_eval do
  def reserved_count_on_hand(variant)
    reserved_stock_item(variant).try(:count_on_hand)
  end

  def reserved_stock_item(variant)
    reserved_stock_location
      .stock_items
      .where(variant: variant)
      .where(user_id: id)
      .order(:id)
      .first
  end

  def reserved_stock_item_or_create(variant, original_stock_location)
    return unless reserved_stock_location
    reserved_stock_item(variant) || Spree::ReservedStockItem.create!(
      variant: variant,
      user_id: id,
      stock_location: reserved_stock_location,
      original_stock_location: original_stock_location
    )
  end

  private

  def reserved_stock_location
    Spree::StockLocation.reserved_items_location
  end
end
