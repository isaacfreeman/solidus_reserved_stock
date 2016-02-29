require "spec_helper"


describe Spree.user_class, type: :model do
  subject { create(:user) }
  let(:original_stock_location) { create(:stock_location) }
  let(:variant) { create(:variant) }
  let(:reserved_stock_location) { Spree::StockLocation.reserved_items_location }

  it "can return information on current reserved items"
end
