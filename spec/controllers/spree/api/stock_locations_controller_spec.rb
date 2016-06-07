require "spec_helper"

module Spree
  describe Api::StockLocationsController, type: :controller do
    render_views

    let!(:stock_location) { create(:stock_location) }

    before do
      stub_authentication!
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#index" do
        it "includes the reserved_items attribute" do
          api_get :index
          expect(json_response["stock_locations"].first).to have_attributes([:reserved_items])
        end
      end
    end
  end
end
