require 'spec_helper'

# Specs modifications in stock_location_decorator
describe Spree::StockLocation, type: :model do
  subject { create(:stock_location_with_items, backorderable_default: true) }
  let(:stock_item) { subject.stock_items.order(:id).first }

  it "has a class method to return the canonical reserved stock location"
  it "creates reserved stock location if not present"
  it "accepts only ReservedStockItems"

  # TODO: StockLocation probably isn't the right place for this. I guess we need
  #       a prioritizer?
  it "is used before other stock locations when processing an order"
end
