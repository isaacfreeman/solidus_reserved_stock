require "spec_helper"

module Spree
  describe Api::ReservedStockItemsController, type: :controller do
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

    before do
      stub_authentication!
    end

    context "as a normal user" do
      it "cannot reserve stock" do
        api_post :reserve, variant: variant, original_stock_location: original_stock_location, user: user, quantity: 4
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

      describe "#reserve" do
        it "reserves a quantity of stock for a given variant" do
          # TODO: Set expires_at
          api_post :reserve,
                   variant: variant,
                   original_stock_location: original_stock_location,
                   user: user,
                   quantity: 4
          expect(response.status).to eq 201
          expect(json_response[:count_on_hand]).to eq 4
          expect(json_response[:expires_at]).to be_nil
        end
        it "returns an appropriate error message on failure" do
          api_post :reserve, variant: "blort"
          expect(response.status).to eq 422
          # TODO: test for a reasonable error message
        end
      end

      describe "#restock" do
        before :each do
          reserved_stock_item
        end
        it "restores all stock if no quantity given" do
          api_post :restock, variant: variant, user: user
          expect(response.status).to eq 201
          expect(json_response[:count_on_hand]).to eq 0
        end
        it "restores some stock if quantity given" do
          api_post :restock, variant: variant, user: user, quantity: 4
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
