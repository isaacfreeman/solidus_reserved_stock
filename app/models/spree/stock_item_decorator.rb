# Validates that regular StockItems can't belong to a reserved stock location
class NotReservedStockLocationValidator < ActiveModel::Validator
  MESSAGE = "StockLocation for a StockItem must not have "\
            "reserved_items? == true. "\
            "Did you mean to create a ReservedStockItem?".freeze
  def validate(record)
    return if record.class == Spree::ReservedStockItem
    stock_location = record.stock_location
    return unless stock_location # Already a validator for this.
    return unless stock_location.reserved_items?
    record.errors[:stock_location] << MESSAGE
  end
end

# Class methods to handle stock locations that contain reserved items
module Spree
  StockItem.class_eval do
    validates_with NotReservedStockLocationValidator
  end
end
