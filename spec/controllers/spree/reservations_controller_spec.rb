require 'spec_helper'

describe Spree::ReservationsController, :type => :controller do
  let(:user) { create(:user) }

  context "#create" do
    it "creates a reserved stock item for the current user"
    it "reduces stock from other locations"
  end

  context "#delete" do
    it "restores tock to the original stock location"
    it "deletes the reserved stock item"
  end

  context "#index" do
    it "returns a list of current reservations"
    it "is only accessible to admins"
  end
end
