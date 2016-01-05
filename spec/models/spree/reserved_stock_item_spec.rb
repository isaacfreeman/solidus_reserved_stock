require 'spec_helper'

# Specs ReservedStockItem subclass to StockItem
describe Spree::ReservedStockItem, type: :model do
  it "belongs to a user"
  it "has an expiry date"
  it "remembers the stock location where stock was reserved"
end
