Spree::Shipment.class_eval do
  def manifest_unstock(item)
    stock_location.unstock(item.variant, item.quantity, self, order.user)
  end
end
