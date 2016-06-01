# Validates that the reserved stock location does not have backorderable_default
class NotBackOrderableDefaultValidator < ActiveModel::Validator
  def validate(record)
    return unless record.reserved_items && record.backorderable_default?
    record.errors[:backorderable_default] << "backorderable_default must be false for reserved stock locations"
  end
end

# Validates that the reserved stock location does not have propagate_all_variants
class NotPropagateAllVariantsValidator < ActiveModel::Validator
  def validate(record)
    return unless record.reserved_items && record.propagate_all_variants?
    record.errors[:propagate_all_variants] << "propagate_all_variants must be false for reserved stock locations"
  end
end

# Class methods to handle stock locations that contain reserved items
# Typically I'd expect there to be only one stock location for reserved items,
# but at this stage we're not enforcing that.
module Spree
  StockLocation.class_eval do
    validates_with NotBackOrderableDefaultValidator
    validates_with NotPropagateAllVariantsValidator

    scope :reserved_items, -> { where(reserved_items: true) }
    scope :not_reserved_items, -> { where(reserved_items: false) }

    def self.reserved_items_location
      return reserved_items.first if reserved_items.any?
      Spree::StockLocation.create(
        name: "Reserved Items",
        reserved_items: true,
        propagate_all_variants: false,
        backorderable_default: false
      )
    end

    def expired_stock_items
      reserved_stock_items.where("expires_at < ?", Time.zone.now)
    end

    def reserved_stock_items
      stock_items.where(type: Spree::ReservedStockItem)
    end
  end
end
