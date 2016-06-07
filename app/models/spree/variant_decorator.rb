Spree::Variant.class_eval do
  # Adds optional user argument
  def total_on_hand(user = nil)
    Spree::Stock::Quantifier.new(self, nil, user).total_on_hand
  end
end
