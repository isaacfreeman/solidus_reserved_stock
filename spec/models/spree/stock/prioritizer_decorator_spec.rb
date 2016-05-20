require "spec_helper"

module Spree
  module Stock
    describe Prioritizer, type: :model do
      let(:original_stock_location) { create(:stock_location) }
      let(:reserved_stock_location) { Spree::StockLocation.reserved_items_location }
      let(:variant) { build(:variant) }

      it "sorts packages from reserved stock location first" do
        regular_package = Package.new(original_stock_location)
        regular_inventory_unit = mock_model(InventoryUnit, variant: variant)
        regular_package.add regular_inventory_unit

        reserved_package = Package.new(reserved_stock_location)
        reserved_inventory_unit = mock_model(InventoryUnit, variant: variant)
        reserved_package.add reserved_inventory_unit

        inventory_units = [regular_inventory_unit, reserved_inventory_unit]
        packages = [regular_package, reserved_package]
        prioritizer = Prioritizer.new(inventory_units, packages)
        packages = prioritizer.prioritized_packages

        expect(packages.first).to eq reserved_package
        expect(packages.second).to eq regular_package
      end
    end
  end
end
