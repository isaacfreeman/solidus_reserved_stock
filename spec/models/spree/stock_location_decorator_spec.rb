require "spec_helper"

# Specs modifications in stock_location_decorator
describe Spree::StockLocation, type: :model do
  subject do
    create(
      :stock_location_with_items,
      backorderable_default: true,
      reserved_items: true
    )
  end
  let(:stock_item) { subject.stock_items.order(:id).first }

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

  # TODO: StockLocation probably isn't the right place for this. I guess we need
  #       a prioritizer?
  it "is used before other stock locations when processing an order"
end
