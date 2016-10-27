# Validates that the reserved stock location does not have backorderable_default
class NotBackOrderableDefaultValidator < ActiveModel::Validator
  def validate(record)
    return unless record.reserved_items && record.backorderable_default?
    record.errors[:backorderable_default] << "backorderable_default must be false for reserved stock locations"
  end
end

# Validates that the reserved stock location doesn't have propagate_all_variants
class NotPropagateAllVariantsValidator < ActiveModel::Validator
  def validate(record)
    return unless record.reserved_items && record.propagate_all_variants?
    record.errors[:propagate_all_variants] << "propagate_all_variants must be false for reserved stock locations"
  end
end

# Class methods to handle stock locations that contain reserved items
module Spree
  StockLocation.class_eval do
    validates_with NotBackOrderableDefaultValidator
    validates_with NotPropagateAllVariantsValidator

    scope :reserved_items, -> { where(reserved_items: true) }
    scope :not_reserved_items, -> { where(reserved_items: false) }

    # Note that this method assumes there's only one stock location for
    # reserved items. This may change in future.
    # An alternative architecture under consideration would be to have a
    # separate reserved items stock location that shadows each regular stock
    # location.
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

# Overridden to add optional user_id argument
module AddOptionalUserArgument
  # Error indicating that we need to know which user a reserved stock item
  # is for, not just the variant as for regular stock items
  class UserRequiredArgumentError < ArgumentError; end

  # TODO: If no original_stock_location given, return a stock item according
  #       to some priority of the regular stock locations, instead of just the
  #       first one we find.
  def stock_item(variant_id, user_id = nil, original_stock_location_id = nil)
    return super(variant_id) unless reserved_items?
    raise(
      UserRequiredArgumentError,
      Spree.t(:user_id_required_for_reserved_stock_location)
    ) unless user_id.present?
    items = stock_items.where(variant_id: variant_id, user_id: user_id)
    items = items.where(
      original_stock_location_id: original_stock_location_id
    ) unless original_stock_location_id.blank?
    items.order(:id).first
  end

  def unstock(variant, quantity, originator = nil, user = nil, original_stock_location = nil)
    return super(
      variant,
      quantity,
      originator = nil
    ) unless reserved_items?
    move(variant, -quantity, originator, user, original_stock_location)
  end

  def move(variant, quantity, originator = nil, user = nil, original_stock_location = nil)
    return super(
      variant,
      quantity,
      originator = nil
    ) unless reserved_items?
    stock_item = stock_item(variant, user, original_stock_location)
    if quantity < 1 && !stock_item
      raise InvalidMovementError, Spree.t(:negative_movement_absent_item)
    end
    stock_item.stock_movements.create!(
      quantity: quantity,
      originator: originator
    )
  end
end
Spree::StockLocation.prepend AddOptionalUserArgument
