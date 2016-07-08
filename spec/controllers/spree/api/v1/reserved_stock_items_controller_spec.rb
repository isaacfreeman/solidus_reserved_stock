require "spec_helper"

module Spree
  describe Api::V1::ReservedStockItemsController, type: :controller do
    render_views

    let(:user) { create(:user) }
    let(:original_stock_location) { create(:stock_location) }
    let(:variant) { create(:variant) }
    let(:reserved_stock_location) { Spree::StockLocation.reserved_items_location }
    let(:reserved_stock_item) do
      create(
        :reserved_stock_item,
        variant: variant,
        stock_location: reserved_stock_location,
        original_stock_location: original_stock_location,
        user: user,
        expires_at: 1.day.from_now,
        backorderable: false
      )
    end
    let(:expired_reserved_stock_item) do
      create(
        :reserved_stock_item,
        variant: variant,
        stock_location: reserved_stock_location,
        original_stock_location: original_stock_location,
        user: user,
        expires_at: 1.day.ago,
        backorderable: false
      )
    end
    let(:reserved_stock_item_attributes) {
      [
        :id,
        :count_on_hand,
        :expires_at,
        :original_stock_location_id,
        :stock_location_id,
        :user_id,
        :variant_id,
        :variant
      ]
    }

    before do
      stub_authentication!
    end

    context "as a normal user" do
      it "cannot list reserved items" do
        api_get :index
        assert_unauthorized!
      end
      it "cannot reserve stock" do
        api_post :reserve,
        variant: variant, original_stock_location: original_stock_location, user: user, quantity: 4
        assert_unauthorized!
      end
      it "cannot restock" do
        api_post :restock, variant: variant, user: user, quantity: 4
        assert_unauthorized!
      end
      it "cannot restock expired" do
        api_post :restock_expired
        assert_unauthorized!
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#index" do
        it "can list reserved stock items" do
          reserved_stock_item
          api_get :index
          expect(response).to be_success
          expect(json_response['reserved_stock_items'].first).to have_attributes(reserved_stock_item_attributes)
          expect(json_response['reserved_stock_items'].first['variant']['sku']).to match variant.sku
        end
        it "can list reserved stock items for a given user" do
          reserved_stock_item
          api_get :index, user_id: user.id
          expect(response).to be_success
          expect(json_response['reserved_stock_items'].first).to have_attributes(reserved_stock_item_attributes)
          expect(json_response['reserved_stock_items'].first['variant']['sku']).to match variant.sku
        end
      end

      describe "#reserve" do
        context "request that will succeed" do
          before do
            stock_item = original_stock_location.stock_item_or_create(variant)
            stock_item.adjust_count_on_hand(10)
          end
          it "reserves a quantity of stock for a given variant" do
            expiry_date = 1.week.from_now
            api_post :reserve,
                     variant_id: variant.id,
                     original_stock_location_id: original_stock_location.id,
                     user_id: user.id,
                     quantity: 4,
                     expires_at: expiry_date
            expect(response.status).to eq 201
            expect(json_response[:count_on_hand]).to eq 4
            expect(json_response[:expires_at]).to eq expiry_date.iso8601(3)
          end
          it "can find variants by sku" do
            api_post :reserve,
                     sku: variant.sku,
                     original_stock_location_id: original_stock_location.id,
                     user_id: user.id,
                     quantity: 4
            expect(response.status).to eq 201
          end
        end
        context "can't find variant" do
          it "returns an approprate error" do
            api_post :reserve,
                     sku: "florb",
                     original_stock_location_id: original_stock_location.id,
                     user_id: user.id,
                     quantity: 4
            expect(response.status).to eq 404
          end
        end
        context "can't find original stock location" do
          it "returns an approprate error" do
            api_post :reserve,
                     sku: variant.sku,
                     original_stock_location_id: 1000,
                     user_id: user.id,
                     quantity: 4
            expect(response.status).to eq 404
          end
        end
        context "can't find user" do
          it "returns an approprate error" do
            api_post :reserve,
                     sku: variant.sku,
                     original_stock_location_id: original_stock_location.id,
                     user_id: 1000,
                     quantity: 4
            expect(response.status).to eq 404
          end
        end
        context "quantity unavailable" do
          it "returns an approprate error" do
            api_post :reserve,
                     sku: variant.sku,
                     original_stock_location_id: original_stock_location.id,
                     user_id: user.id,
                     quantity: 10000
            expect(response.status).to eq 422
          end
        end
        context "parameters are missing" do
          it "returns JSON API formatted errors" do
            api_post :reserve
            expect(response.status).to eq 422
            body = JSON.parse response.body
          end
        end
      end

      describe "#restock" do
        before :each do
          reserved_stock_item
        end
        it "restores all stock if no quantity given" do
          api_post :restock, variant_id: variant.id, user_id: user.id, original_stock_location_id: original_stock_location.id
          expect(response.status).to eq 201
          expect(json_response[:count_on_hand]).to eq 0
        end
        it "restores some stock if quantity given" do
          api_post :restock, variant_id: variant.id, user_id: user.id, original_stock_location_id: original_stock_location.id, quantity: 4
          expect(response.status).to eq 201
          expect(json_response[:count_on_hand]).to eq 6
        end
        it "returns an appropriate error message on failure" do
          api_post :restock, variant: "flarn"
          expect(response.status).to eq 422
          # TODO: test for a reasonable error message
        end
      end

      describe "#restock_expired" do
        it "restores expired reservations" do
          expired_reserved_stock_item
          api_post :restock_expired
          expect(response.status).to eq 204
        end
      end
    end
  end
end
