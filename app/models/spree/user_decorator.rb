Spree.user_class.class_eval do
  has_many :reserved_stock_items, foreign_key: :user_id

  before_destroy :restock_all_reserved_items!

  def reserved_count_on_hand(variant, original_stock_location)
    reserved_stock_item(variant, original_stock_location).try(:count_on_hand) || 0
  end

  def reserved_stock_items_for_variant(variant)
    reserved_stock_location
      .stock_items
      .where(variant: variant)
      .where(user_id: id)
      .order(:id)
  end

  def reserved_stock_item(variant, original_stock_location)
    reserved_stock_items_for_variant(variant)
      .where(original_stock_location_id: original_stock_location.id)
      .first
  end

  def reserved_stock_item_or_create(variant, original_stock_location, expires_at = nil)
    return unless reserved_stock_location
    reserved_stock_item(variant, original_stock_location) || Spree::ReservedStockItem.create!(
      variant: variant,
      user_id: id,
      stock_location: reserved_stock_location,
      original_stock_location: original_stock_location,
      expires_at: expires_at
    )
  end

  private

  def reserved_stock_location
    Spree::StockLocation.reserved_items_location
  end

  def restock_all_reserved_items!
    reserved_stock_items.each do |reserved_stock_item|
      Spree::Stock::Reserver.new(reserved_stock_item.variant, self, reserved_stock_item.original_stock_location).restock
    end
  end
end
