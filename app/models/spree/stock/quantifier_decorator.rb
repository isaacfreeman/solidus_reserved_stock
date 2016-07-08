Spree::Stock::Quantifier.class_eval do
  def initialize(variant, stock_location = nil, user = nil)
    @variant = variant
    where_args = { variant_id: @variant }
    if stock_location
      where_args.merge!(stock_location: stock_location)
    else
      where_args.merge!(
        Spree::StockLocation.table_name => {
          active: true,
          reserved_items: false
        }
      )
    end
    @stock_items = Spree::StockItem.joins(:stock_location).where(where_args)

    if user && user.reserved_stock_items_for_variant(variant)
      @stock_items += user.reserved_stock_items_for_variant(variant).to_a
    end
  end

  def total_on_hand
    if @variant.should_track_inventory?
      stock_items.to_a.sum(&:count_on_hand)
    else
      Float::INFINITY
    end
  end
end
