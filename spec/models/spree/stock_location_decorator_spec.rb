require "spec_helper"

# Specs modifications in stock_location_decorator
describe Spree::StockLocation, type: :model do
  subject do
    create(
      :stock_location,
      backorderable_default: true,
      reserved_items: true
    )
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

  # TODO: must have propagate_all_variants be false if reserved_items

  # TODO: StockLocation probably isn't the right place for this. I guess we need
  #       a prioritizer?
  it "is used before other stock locations when processing an order"

  context "#count_on_hand" do
    context "if reserved_items is true" do
      it "returns count on hand for a given variant and user"
    end
    context "if reserved_items is false" do
      it "doesn't accept a user argument"
    end
  end
end
