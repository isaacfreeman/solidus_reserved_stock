require "spec_helper"

# Specs modifications in stock_location_decorator
describe Spree::StockLocation, type: :model do
  subject do
    create(
      :stock_location,
      backorderable_default: false,
      propagate_all_variants: false,
      reserved_items: true
    )
  end

  context "validation" do
    context "when reserved_items is true" do
      it "is invalid if backorderable_default is true" do
        reserved_stock_item = build(
          :stock_location,
          backorderable_default: true,
          propagate_all_variants: false,
          reserved_items: true
        )
        expect(reserved_stock_item).to be_invalid
      end
      it "is invalid if propagate_all_variants is true" do
        reserved_stock_item = build(
          :stock_location,
          backorderable_default: false,
          propagate_all_variants: true,
          reserved_items: true
        )
        expect(reserved_stock_item).to be_invalid
      end
    end
  end
  context ".reserved_items_location" do
    it "can return the existing reserved stock location" do
      subject
      expect(Spree::StockLocation.reserved_items_location).to eq subject
    end
    it "creates reserved stock location if not present" do
      reserved_items_location = Spree::StockLocation.reserved_items_location
      expect(reserved_items_location).to be_a Spree::StockLocation
      expect(reserved_items_location.reserved_items?).to be true
    end
  end
end
