require 'spec_helper'

# Specs ReservedStockItem subclass to StockItem
describe Spree::ReservedStockItem, type: :model do
  it "belongs to a user"
  it "has an expiry date"
  it "remembers the stock location where stock was reserved"

  context "#before_destroy" do
    it "restores stock to the original_stock_location"
  end

  context "#after_create" do
    it "reduces the quantity of stock items at original_stock_location"
  end

  context ".destroy_expired" do
    it "removes all expired ReservedStockItems"
    it "can be called from a Rake task"
  end
end
