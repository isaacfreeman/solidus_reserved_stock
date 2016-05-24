require "spec_helper"

module Spree
  describe Spree::Api::V1::Validators::ReserveStockParamsValidator do
    subject { Spree::Api::V1::Validators::ReserveStockParamsValidator }
    let(:valid_parameters) {
      {
        variant_id: 1,
        original_stock_location_id: 1,
        user_id: 1,
        quantity: 1,
        expires_at: 1.day.from_now
      }
    }

    it "fails validation when there's no variant_id or sku parameter" do
      validator = subject.new(valid_parameters.except :variant_id)
      expect(validator.validate).to be false
      expect(validator.errors).to eq [{ status: 422, detail: "Parameters must include either 'variant_id' or 'sku'"}]
    end

    it "fails validation when there's no original_stock_location_id parameter" do
      validator = subject.new(valid_parameters.except :original_stock_location_id)
      expect(validator.validate).to be false
      expect(validator.errors).to eq [{ status: 422, detail: "Parameters must include 'original_stock_location_id'"}]
    end

    it "fails validation when there's no user_id parameter" do
      validator = subject.new(valid_parameters.except :user_id)
      expect(validator.validate).to be false
      expect(validator.errors).to eq [{ status: 422, detail: "Parameters must include 'user_id'"}]
    end

    it "fails validation when there's no quantity parameter" do
      validator = subject.new(valid_parameters.except :quantity)
      expect(validator.validate).to be false
      expect(validator.errors).to eq [{ status: 422, detail: "Parameters must include 'quantity'"}]
    end

  end
end
