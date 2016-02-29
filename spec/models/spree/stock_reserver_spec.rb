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
  let(:original_stock_location) { create(:stock_location) }
  let(:variant) { create(:variant) }
  let(:reserved_stock_location) { Spree::StockLocation.reserved_items_location }

  subject { Spree::StockReserver.new }

  context "#reserve" do
    before(:each) do
      stock_item = original_stock_location.stock_item_or_create(variant)
      stock_item.adjust_count_on_hand(10)
      subject.reserve(variant, original_stock_location, user, 4)
    end
    it "moves stock items to the reserved stock location" do
      expect(user.reserved_count_on_hand(variant)).to eq 4
      expect(original_stock_location.count_on_hand(variant)).to eq 6
    end
    it "remembers original stock location" do
      reserved_stock_item = user.reserved_stock_item(variant)
      expect(reserved_stock_item.original_stock_location).to eq original_stock_location
    end
  end

  context "#restock" do
    it "restores stock to the original_stock_location" do
      # original_stock_location = create(:stock_location)
      # variant = create(:variant)
      # stock_item = original_stock_location.stock_item_or_create(variant)
      # stock_item.adjust_count_on_hand(10)
      # subject.reserve(variant, original_stock_location, user, 10)
      # # TODO: replace the above three lines with something like below
      # # reserved_stock_item = create(
      # #   :reserved_stock_item,
      # #   variant: variant,
      # #   user: user,
      # #   stock_location: Spree::StockLocation.reserved_items_location
      # # )
      # expect(original_stock_location.count_on_hand(variant)).to eq 0
      # expect(Spree::StockLocation.reserved_items_location.count_on_hand(variant)).to eq 10
      #
      # subject.restock(reserved_stock_item)
      # expect(original_stock_location.count_on_hand(variant)).to eq 10
      # expect(Spree::StockLocation.reserved_items_location.count_on_hand(variant)).to eq 0
    end
  end

  context "#restock_expired" do
    it "restores all expired ReservedStockItems" do
    end
  end
end
