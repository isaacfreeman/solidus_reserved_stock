require "spec_helper"

describe Spree::Stock::Coordinator, type: :model do
  let!(:store) { create(:store, default: true) }
  # Force setting up a normal stock location before we create variant,
  # otherwise we get too many stock locations
  let!(:normal_stock_location) { create(:stock_location) }
  let(:variant) { create(:variant) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:reserved_stock_location) { Spree::StockLocation.reserved_items_location }
  let(:normal_stock_item) do
    normal_stock_location.stock_item(variant)
  end
  let(:reserved_stock_item_for_user) do
    create(
      :reserved_stock_item,
      backorderable: false,
      original_stock_location: normal_stock_location,
      stock_location: reserved_stock_location,
      user: user,
      variant: variant
    )
  end
  let(:reserved_stock_item_for_other_user) do
    create(
      :reserved_stock_item,
      backorderable: false,
      original_stock_location: normal_stock_location,
      stock_location: reserved_stock_location,
      user: other_user,
      variant: variant
    )
  end
  let(:order) { Spree::Order.new(store: store, user: user) }
  subject { Spree::Stock::Coordinator.new(order) }

  context "#packages" do
    it "uses items reserved for the user first" do
      reserved_stock_item_for_user.set_count_on_hand(5)
      normal_stock_item.set_count_on_hand(5)
      Spree::OrderContents.new(order).add(variant, 2)
      packages = subject.send(:packages)
      expect(packages.count).to eq 1
      expect(packages.first.stock_location).to eq reserved_stock_location
      expect(packages.first.contents.count).to eq 2
    end
    it "uses non-reserved items if there aren't enough reserved items" do
      reserved_stock_item_for_user.set_count_on_hand(5)
      normal_stock_item.set_count_on_hand(5)
      Spree::OrderContents.new(order).add(variant, 7)
      packages = subject.send(:packages)
      expect(packages.count).to eq 2
      expect(packages.first.stock_location).to eq reserved_stock_location
      expect(packages.first.contents.count).to eq 5
      expect(packages.second.stock_location).to eq normal_stock_location
      expect(packages.second.contents.count).to eq 2
    end
    it "doesn't use items reserved by a different user" do
      reserved_stock_item_for_other_user.set_count_on_hand(5)
      normal_stock_item.set_count_on_hand(5)
      Spree::OrderContents.new(order).add(variant, 2)
      packages = subject.send(:packages)
      expect(packages.count).to eq 1
      expect(packages.first.stock_location).to eq normal_stock_location
      expect(packages.first.contents.count).to eq 2
    end
  end
end
