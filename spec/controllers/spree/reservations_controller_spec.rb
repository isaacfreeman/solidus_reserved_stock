require 'spec_helper'

describe Spree::ReservationsController, :type => :controller do
  let(:user) { create(:user) }

  context "#create" do
    it "creates a reserved stock item"
  end

  context "#delete" do
    it "deletes the reserved stock item"
  end

  context "#index" do
    it "returns a list of current reservations"
    it "is only accessible to admins"
  end
end
