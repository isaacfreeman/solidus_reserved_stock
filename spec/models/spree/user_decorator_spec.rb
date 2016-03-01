require "spec_helper"


describe Spree.user_class, type: :model do
  subject { create(:user) }
  let(:original_stock_location) { create(:stock_location) }
  let(:variant) { create(:variant) }
  let(:reserved_stock_location) { Spree::StockLocation.reserved_items_location }
  let(:reserved_stock_item) do
    create(
      :reserved_stock_item,
      variant: variant,
      stock_location: reserved_stock_location,
      original_stock_location: original_stock_location,
      user: subject,
      expires_at: 1.day.from_now
    )
  end

  context "#reserved_count_on_hand" do
    it "returns reserved quantity for a variant" do
      reserved_stock_item
      expect(
        subject.reserved_count_on_hand(variant)
      ).to eq 10
    end
  end

  context "#reserved_stock_item" do
    it "returns the reserved_stock_item for a variant" do
      reserved_stock_item
      expect(
        subject.reserved_stock_item(variant)
      ).to eq reserved_stock_item
    end
  end

  context "#reserved_stock_item_or_create" do
    it "returns an existing reserved_stock_item" do
      reserved_stock_item
      expect(
        subject.reserved_stock_item_or_create(variant, original_stock_location)
      ).to eq reserved_stock_item
    end
    it "creates and returns a reserved_stock_item if none exists" do
      expect(subject.reserved_stock_item(variant)).to be_nil
      subject.reserved_stock_item_or_create(variant, original_stock_location)
      expect(subject.reserved_stock_item(variant)).not_to be_nil
    end
  end
end
