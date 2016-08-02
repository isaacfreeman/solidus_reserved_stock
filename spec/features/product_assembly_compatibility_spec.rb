require "spec_helper"

# Specs for compatibility with the solidus_product_assembly gem
# TODO: Rewrite as unit tests on reserver
describe "Compatibility with solidus_product_assembly" do
  let(:bundle) { create(:variant) }
  let(:part_1) { create(:variant) }
  let(:part_2) { create(:variant) }
  let(:parts) { [part_1, part_2] }
  let!(:bundle_parts) { bundle.product.parts << parts }

  let(:stock_location) { create(:stock_location) }
  let(:reserved_stock_location) { Spree::StockLocation.reserved_items_location }
  let(:user) { create(:user) }

  describe Spree::Stock::Reserver do
    subject { Spree::Stock::Reserver.new(bundle, user, stock_location) }
    describe "#reserve" do
      context "when there are enough parts to reserve" do
        before do
          set_stock(stock_location, bundle, 10)
          set_stock(stock_location, part_1, 10)
          set_stock(stock_location, part_2, 10)
          subject.reserve(5)
        end
        it "also reserves parts" do
          parts.each do |part|
            expect(user.reserved_count_on_hand(part, stock_location)).to eq 5
          end
        end
        it "sets same expiry date for bundle and parts" do
          bundle_reserve = user.reserved_stock_item(bundle, stock_location)
          parts.each do |part|
            part_reserve = user.reserved_stock_item(part, stock_location)
            expect(part_reserve.expires_at).to eq bundle_reserve.expires_at
          end
        end
      end
      context "when there aren't enough parts to reserve" do
        before do
          set_stock(stock_location, bundle, 10)
          set_stock(stock_location, part_1, 2)
          set_stock(stock_location, part_2, 2)
        end
        it "raises a sensible error" do
          expect do
            subject.reserve(5)
          end.to raise_error Spree::Stock::Reserver::InvalidQuantityError
        end
        it "doesn't reserve the bundle" do
          expect { subject.reserve(5) rescue nil }.not_to change {
            user.reserved_count_on_hand(bundle, stock_location)
          }
        end
      end
    end
    describe "#restock" do
      before do
        set_stock(stock_location, bundle, 10)
        set_stock(stock_location, part_1, 10)
        set_stock(stock_location, part_2, 10)
        subject.reserve(5)
        subject.restock(5)
      end
      it "also restocks parts" do
        parts.each do |part|
          expect(user.reserved_count_on_hand(part, stock_location)).to eq 0
        end
      end
      # TODO: What if we've sold some of the parts, so we can't restock as many
      #       parts as the bundle quantity?
      it "does something sensible if we can't restock all the parts"
    end
  end

  describe "building shipments (packages?) for a bundle" do
    let(:order) { Spree::Order.create(user: user) }
    let(:shipments) { order.create_proposed_shipments }

    context "user doesn't have the bundle reserved" do
      context "user has parts reserved" do
        let!(:line_item) { order.contents.add(bundle, 5) }
        before do
          set_stock(stock_location, bundle, 10)
          set_stock(stock_location, part_1, 10)
          set_stock(stock_location, part_2, 10)
          Spree::Stock::Reserver.new(part_1, user, stock_location).reserve(5)
          Spree::Stock::Reserver.new(part_2, user, stock_location).reserve(5)
          order.create_proposed_shipments
        end
        it "uses reserved parts" do
          order.shipments.each do |shipment|
            expect(shipment.stock_location).to eq reserved_stock_location
          end
        end
      end
    end

    context "user has the bundle reserved" do
      let!(:line_item) { order.contents.add(bundle, 2) }
      context "user has parts reserved" do
        before do
          set_stock(stock_location, bundle, 4)
          set_stock(stock_location, part_1, 4)
          set_stock(stock_location, part_2, 4)
          Spree::Stock::Reserver.new(bundle, user, stock_location).reserve(2)
          # n.b. parts will also be reserved
          order.create_proposed_shipments
        end
        it "uses the reserved parts" do
          order.shipments.each do |shipment|
            expect(shipment.stock_location).to eq reserved_stock_location
          end
        end
      end
      context "parts reserved from different stock locations" do
        let(:other_stock_location) { create(:stock_location) }
        before do
          set_stock(stock_location, bundle, 4)
          set_stock(stock_location, part_1, 4)
          set_stock(stock_location, part_2, 4)
          set_stock(other_stock_location, part_2, 4)
          Spree::Stock::Reserver.new(bundle, user, stock_location).reserve(2)
          Spree::Stock::Reserver.new(part_2, user, stock_location).restock(2)
          Spree::Stock::Reserver.new(part_2, user, other_stock_location).reserve(2)
          # At this point we should have bundle and part_1 reserved from
          # stock_location, but part_2 reserved from other_stock_location
          order.create_proposed_shipments
        end
        it "uses the reserved parts" do
          order.shipments.each do |shipment|
            expect(shipment.stock_location).to eq reserved_stock_location
          end
        end
      end
      context "user doesn't have enough parts reserved" do
        before do
          set_stock(stock_location, bundle, 4)
          set_stock(stock_location, part_1, 4)
          set_stock(stock_location, part_2, 4)
          Spree::Stock::Reserver.new(bundle, user, stock_location).reserve(2)
          Spree::Stock::Reserver.new(part_2, user, stock_location).restock(2)
          # At this point we should have bundle and part_1 reserved, but no
          # reserves for part_2
          order.create_proposed_shipments
        end
        it "uses reserved parts, then some unreserved parts" do
          reserve_shipments = order.shipments.where(stock_location: reserved_stock_location)
          regular_shipments = order.shipments.where(stock_location: stock_location)
          expect(reserve_shipments.count).to eq 1
          expect(regular_shipments.count).to eq 1
        end
      end
    end
  end
end

def set_stock(stock_location, variant, quantity)
  stock_location.stock_item_or_create(variant).set_count_on_hand(quantity)
end
