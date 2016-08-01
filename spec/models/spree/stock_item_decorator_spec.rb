require "spec_helper"

# Specs ReservedStockItem subclass to StockItem
describe Spree::StockItem, type: :model do
  let(:reserved_stock_location) do
    create(
      :stock_location,
      reserved_items: true,
      propagate_all_variants: false,
      backorderable_default: false
    )
  end

  context "validation" do
    context "stock location" do
      it "is invalid if its stock_location is for reserved_items" do
        stock_item = build(
          :stock_item,
          stock_location: reserved_stock_location
        )
        expect(stock_item).to be_invalid
      end
    end
  end
end
