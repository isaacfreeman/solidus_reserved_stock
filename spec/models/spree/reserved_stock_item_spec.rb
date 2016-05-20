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
  let(:user) { create(:user) }
  # TODO: specify variant here for clarity
  subject do
    create(
      :reserved_stock_item,
      variant: FactoryGirl.create(:variant),
      stock_location: reserved_stock_location,
      user: user,
      backorderable: false
    )
  end

  context "validation" do
    context "stock location" do
      it "can be valid" do
        expect(subject).to be_valid
      end
      it "is invalid if backorderable" do
        reserved_stock_item = build(
          :reserved_stock_item,
          variant: FactoryGirl.create(:variant),
          stock_location: reserved_stock_location,
          user: user,
          backorderable: true
        )
        expect(reserved_stock_item).to be_invalid
      end
      it "is invalid if its stock_location is not for reserved_items" do
        invalid_base_stock_location = create(
          :stock_location,
          reserved_items: false,
          propagate_all_variants: false
        )
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: invalid_base_stock_location,
          backorderable: false
        )
        expect(reserved_stock_item).to be_invalid
      end
    end
    context "user" do
      it "is invalid without a user" do
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: reserved_stock_location,
          user: nil,
          backorderable: false
        )
        expect(reserved_stock_item).to be_invalid
      end
      it "is invalid if variant and user are not unique" do
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: reserved_stock_location,
          variant: subject.variant,
          user: subject.user,
          backorderable: false
        )
        expect(reserved_stock_item).to be_invalid
      end
      it "is valid if variant is not unique, but user is" do
        different_user = create(:user)
        reserved_stock_item = build(
          :reserved_stock_item,
          stock_location: reserved_stock_location,
          variant: subject.variant,
          user: different_user,
          backorderable: false
        )
        expect(reserved_stock_item).to be_valid
      end
    end
  end
  context "DB constraints" do
    it "can save two items with same variant but different user" do
      different_user = create(:user)
      reserved_stock_item = build(
        :reserved_stock_item,
        stock_location: reserved_stock_location,
        variant: subject.variant,
        user: different_user,
        backorderable: false
      )
      reserved_stock_item.save
      expect(Spree::ReservedStockItem.count).to eq 2
    end
  end
end
