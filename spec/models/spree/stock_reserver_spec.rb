require "spec_helper"

# Specs ReservedStockItem subclass to StockItem
describe Spree::StockReserver, type: :model do
  # let(:reserved_stock_location) do
  #   create(
  #     :stock_location,
  #     reserved_items: true,
  #     propagate_all_variants: false
  #   )
  # end
  let(:user) { create(:user) }

  subject { Spree::StockReserver.new }

  context "#reserve" do
    it "reduces the quantity of stock items at original_stock_location" do
      original_stock_location = create(:stock_location)
      variant = create(:variant)
      stock_item = original_stock_location.stock_item_or_create(variant)
      stock_item.adjust_count_on_hand(10)

      expect(original_stock_location.count_on_hand(variant)).to eq 10
      subject.reserve(variant, original_stock_location, user, 4)
      expect(Spree::StockLocation.reserved_items_location.count_on_hand(variant)).to eq 4
      expect(original_stock_location.count_on_hand(variant)).to eq 6
    end
    it "remembers original stock location"
  end

  context "#restock" do
    it "restores stock to the original_stock_location"
  end

  context "#restock_expired" do
    it "restores all expired ReservedStockItems" do
    end
  end
end
