object @reserved_stock_item
attributes :id, :count_on_hand, :expires_at, :original_stock_location_id, :stock_location_id, :user_id, 
child(:variant) do
  extends "spree/api/variants/small"
end
