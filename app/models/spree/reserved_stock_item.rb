# Validates that the StockLocation is specifically for reserved stock
class ReservedStockLocationValidator < ActiveModel::Validator
  def validate(record)
    return unless record.stock_location # Missing stock location should be caught by other validator
    return if record.stock_location.reserved_items?
    record.errors[:stock_location] << "StockLocation for ReservedStockItems must have reserved_items? == true"
  end
end

# Validates that the reserved stock item is not backorderable
class NotBackOrderableValidator < ActiveModel::Validator
  def validate(record)
    return unless record.backorderable?
    record.errors[:backorderable] << "ReservedStockItems must not be backorderable"
  end
end

module Spree
  # A StockItem that's been reserved by a customer. It will be stored in a
  # dedicated StockLocation, but rmembers the original StockLocation for the
  # items, so the can be restored if the reservation expiresor is cancelled.
  class ReservedStockItem < Spree::StockItem
    include ActiveModel::Validations

    belongs_to :user, class_name: Spree::UserClassHandle.new

    belongs_to :original_stock_location, class_name: Spree::StockLocation

    # Remove 'variant_id' attribute from its existing uniqueness validator
    # (effectively disabling it) so we can add a new uniqueness validator that
    # is scoped to user_id. We want multiple users to be able to reserve the
    # same variant.
    variant_id_uniqueness_validator = validators_on(:variant_id).detect do |validator|
      validator.is_a? ActiveRecord::Validations::UniquenessValidator
    end
    variant_id_uniqueness_validator.attributes.delete(:variant_id) if variant_id_uniqueness_validator

    validates_with ReservedStockLocationValidator
    validates_with NotBackOrderableValidator
    validates_uniqueness_of :variant_id,
      scope: [
        :stock_location_id,
        :deleted_at,
        :user_id,
        :original_stock_location_id
      ]
    validates :user_id, presence: true
    validates :original_stock_location_id, presence: true
  end
end
