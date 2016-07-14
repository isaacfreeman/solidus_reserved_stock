require "spec_helper"

# TODO: Need to supply user argument in the appropriate places
#       - LineItem#sufficient_stock?
#       - Spree::Stock::AvailabilityValidator
#       - Variant#can_supply?
#       - _cart_form (give it the current user)
describe Spree::Stock::Quantifier, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:original_stock_location) { create(:stock_location) }
  let(:variant) { create(:variant) }

  context "#total_on_hand" do
    before(:each) do
      stock_item = original_stock_location.stock_item_or_create(variant)
      stock_item.adjust_count_on_hand(10)
      Spree::Stock::Reserver.new(variant, user, original_stock_location).reserve(4)
    end
    context "with a user argument" do
      it "includes reserved stock for user" do
        subject = Spree::Stock::Quantifier.new(variant, nil, user)
        expect(subject.total_on_hand).to eq(10)
      end
      it "excludes reserved stock for other users" do
        subject = Spree::Stock::Quantifier.new(variant, nil, other_user)
        expect(subject.total_on_hand).to eq(6)
      end
    end
    context "with no user argument" do
      it "excludes reserved stock" do
        subject = Spree::Stock::Quantifier.new(variant)
        expect(subject.total_on_hand).to eq(6)
      end
    end
  end
end
