require "spec_helper"

# Specs modifications in stock_location_decorator
describe Spree::StockLocation, type: :model do
  let(:user) { create(:user) }

  context ".reserved_items_location" do
    it "can return the existing reserved stock location" do
      existing_reserved_stock_location = create(
        :stock_location,
        backorderable_default: false,
        propagate_all_variants: false,
        reserved_items: true
      )
      expect(Spree::StockLocation.reserved_items_location).to eq existing_reserved_stock_location
    end
    it "creates reserved stock location if not present" do
      reserved_items_location = Spree::StockLocation.reserved_items_location
      expect(reserved_items_location).to be_a Spree::StockLocation
      expect(reserved_items_location.reserved_items?).to be true
    end
  end

  context "when reserved_items is true" do
    context "validation" do
      it "is invalid if backorderable_default is true" do
        reserved_stock_item = build(
          :stock_location,
          backorderable_default: true,
          propagate_all_variants: false,
          reserved_items: true
        )
        expect(reserved_stock_item).to be_invalid
      end
      it "is invalid if propagate_all_variants is true" do
        reserved_stock_item = build(
          :stock_location,
          backorderable_default: false,
          propagate_all_variants: true,
          reserved_items: true
        )
        expect(reserved_stock_item).to be_invalid
      end
    end
    context "#stock_item" do
      let(:other_user) { create(:user) }
      let(:original_stock_location) { create(:stock_location) }
      let(:variant) { create(:variant) }
      let(:reserved_stock_item) do
        create(
          :reserved_stock_item,
          variant: variant,
          stock_location: subject,
          original_stock_location: original_stock_location,
          user: user,
          expires_at: 1.day.from_now,
          backorderable: false
        )
      end
      let(:other_user_reserved_stock_item) do
        create(
          :reserved_stock_item,
          variant: variant,
          stock_location: subject,
          original_stock_location: original_stock_location,
          user: other_user,
          expires_at: 1.day.from_now,
          backorderable: false
        )
      end
      subject do
        create(
          :stock_location,
          backorderable_default: false,
          propagate_all_variants: false,
          reserved_items: true
        )
      end
      let(:first_stock_item) { subject.stock_items.order(:id).first }
      context "when a user argument is given" do
        it "returns the reserved_stock_item for the given user_id" do
          other_user_reserved_stock_item
          reserved_stock_item
          expect(first_stock_item).to eq other_user_reserved_stock_item
          expect(subject.stock_item(variant.id, user.id)).to eq reserved_stock_item
        end
      end
      context "when no user argument is given" do
        it "raises an error" do
          expect do
            subject.stock_item(variant.id)
          end.to raise_error Spree::StockLocation::UserRequiredArgumentError
        end
      end
    end
  end
  context "when reserved_items is false" do
    subject { create(:stock_location_with_items, backorderable_default: true) }
    let(:stock_item) { subject.stock_items.order(:id).first }
    let(:variant) { stock_item.variant }

    context "#stock_item" do
      context "when a user argument is given" do
        context "user is silently ignored" do
          it "finds a stock_item for a variant" do
            stock_item = subject.stock_item(variant, user)
            expect(stock_item.count_on_hand).to eq 10
          end

          it "finds a stock_item for a variant by id" do
            stock_item = subject.stock_item(variant.id, user)
            expect(stock_item.variant).to eq variant
          end

          it "returns nil when stock_item is not found for variant" do
            stock_item = subject.stock_item(100, user)
            expect(stock_item).to be_nil
          end
        end
      end
      context "when no user argument is given" do
        context "normal behaviour applies" do
          it "finds a stock_item for a variant" do
            stock_item = subject.stock_item(variant)
            expect(stock_item.count_on_hand).to eq 10
          end

          it "finds a stock_item for a variant by id" do
            stock_item = subject.stock_item(variant.id)
            expect(stock_item.variant).to eq variant
          end

          it "returns nil when stock_item is not found for variant" do
            stock_item = subject.stock_item(100)
            expect(stock_item).to be_nil
          end
        end
      end
    end
  end
end
