require "spec_helper"

module Spree
  module Stock
    describe Coordinator, type: :model do
      # Force setting up a normal stock lcoation before we create variant,
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
      let(:order) { Spree::Order.new(user: user) }
      subject { Coordinator.new(order) }

      # TODO: Consider moving these specs down to the class that actually decides, once we know which that is
      # build_packages set sup possible packages, but they're winnowed down somewhere after that
      context "#packages" do
        it "uses items reserved for the user first" do
          reserved_stock_item_for_user.set_count_on_hand(5)
          normal_stock_item.set_count_on_hand(5)
          Spree::OrderContents.new(order).add(variant, 2)
          packages = subject.packages
          expect(packages.count).to eq 1
          expect(packages.first.stock_location).to eq reserved_stock_location
          expect(packages.first.contents.count).to eq 2
        end
        it "uses non-reserved items if there aren't enough reserved items" do
          reserved_stock_item_for_user.set_count_on_hand(5)
          normal_stock_item.set_count_on_hand(5)
          Spree::OrderContents.new(order).add(variant, 7)
          packages = subject.packages
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
          packages = subject.packages
          expect(packages.count).to eq 1
          expect(packages.first.stock_location).to eq normal_stock_location
          expect(packages.first.contents.count).to eq 2
        end
      end
    end
  end
end
