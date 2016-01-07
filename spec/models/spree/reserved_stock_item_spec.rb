require "spec_helper"

# Specs ReservedStockItem subclass to StockItem
describe Spree::ReservedStockItem, type: :model do
  let(:reserved_stock_location) do
    create(
      :stock_location,
      reserved_items: true,
      propagate_all_variants: false
    )
  end
  let (:user) { create(:user) }
  # TODO: specify variant here for clarity
  subject do
    create(
      :reserved_stock_item,
      stock_location: reserved_stock_location,
      user: user
    )
  end

  context "validation" do
    context "stock location" do
      it "is valid if its stock_location is for reserved_items" do
        expect(subject).to be_valid
      end
      it "is invalid if its stock_location is not for reserved_items" do
        invalid_base_stock_location = create(
          :stock_location,
          reserved_items: false,
          propagate_all_variants: false
        )
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: invalid_base_stock_location
        )
        expect(reserved_stock_item).to be_invalid
      end
    end
    context "user" do
      it "is invalid without a user" do
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: reserved_stock_location,
          user: nil
        )
        expect(reserved_stock_item).to be_invalid
      end
      it "is invalid if variant and user are not unique" do
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: reserved_stock_location,
          variant: subject.variant,
          user: subject.user
        )
        expect(reserved_stock_item).to be_invalid
      end
      it "is valid if variant is not unique, but user is" do
        different_user = create(:user)
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: reserved_stock_location,
          variant: subject.variant,
          user: different_user
        )
        expect(reserved_stock_item).to be_valid
      end
    end
  end

  it "has an expiry date"
  it "remembers the stock location where stock was reserved"

  context "#before_destroy" do
    it "restores stock to the original_stock_location"
  end

  context "#after_create" do
    it "reduces the quantity of stock items at original_stock_location"
  end

  context ".destroy_expired" do
    it "removes all expired ReservedStockItems"
    it "can be called from a Rake task"
  end
end
