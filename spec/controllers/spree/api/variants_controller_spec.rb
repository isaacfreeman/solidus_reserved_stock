require "spec_helper"

module Spree
  describe Api::VariantsController, type: :controller do
    render_views

    let(:variant) { create(:variant) }
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:original_stock_location) { create(:stock_location) }

    before do
      stub_authentication!
      stock_item = original_stock_location.stock_item_or_create(variant)
      stock_item.adjust_count_on_hand(10)
      Spree::Stock::Reserver.new.reserve(
        variant,
        original_stock_location,
        user,
        4
      )
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#show" do
        context "total_on_hand" do
          context "when given user" do
            it "returns total that includes reserved stock" do
              api_get :show, id: variant.id, user_id: user.id
              expect(json_response[:total_on_hand]).to eq 10
            end
          end
          context "when given no user" do
            it "returns total that includes reserved stock" do
              api_get :show, id: variant.id
              expect(json_response[:total_on_hand]).to eq 6
            end
          end
          context "when given a different user" do
            it "returns total that includes reserved stock" do
              api_get :show, id: variant.id, user_id: other_user.id
              expect(json_response[:total_on_hand]).to eq 6
            end
          end
        end
        context "stock_items" do
          context "when given user" do
            it "returns total that includes reserved stock"
          end
          context "when given no user" do
            it "returns total that includes reserved stock"
          end
          context "when given a different user" do
            it "returns total that includes reserved stock"
          end
        end
      end
    end
  end
end
