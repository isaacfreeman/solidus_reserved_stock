Spree::Stock::Coordinator.class_eval do
  private

  # Overridden so that users only see their own reserved stock items, and not
  # those reserved by other users
  #
  def stock_location_variant_ids
    location_variant_ids = Spree::StockItem.
      where(variant_id: unallocated_variant_ids).
      where(user_id: [order.user_id, nil]).   # only change is adding this line
      joins(:stock_location).
      merge(Spree::StockLocation.active).
      pluck(:stock_location_id, :variant_id)

    location_lookup = Spree::StockLocation.
      where(id: location_variant_ids.map(&:first).uniq).
      map { |l| [l.id, l] }.
      to_h
    hash = location_variant_ids.each_with_object({}) do |(location_id, variant_id), hash|
      location = location_lookup[location_id]
      hash[location] ||= Set.new
      hash[location] << variant_id
    end
    hash
  end
end