Spree::Product.class_eval do
  # Don't count reserved stock, unless a user argument is given
  def total_on_hand(user = nil)
    if any_variants_not_track_inventory?
      Float::INFINITY
    else
      unreserved_count = stock_items
                         .where("type IS NULL OR type <> 'Spree::ReservedStockItem'")
                         .sum(:count_on_hand)
      return unreserved_count unless user.present?
      reserved_count = stock_items
                       .where("type = 'Spree::ReservedStockItem'")
                       .where(user_id: user.id)
                       .sum(:count_on_hand)
      unreserved_count + reserved_count
    end
  end
end
