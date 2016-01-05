require "spec_helper"

# Specs ReservedStockItem subclass to StockItem
describe Spree::ReservedStockItem, type: :model do
  context "validation" do
    it "is valid if its stock_location is for reserved_items"
    it "is invalid if its stock_location is not for reserved_items"
  end

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
