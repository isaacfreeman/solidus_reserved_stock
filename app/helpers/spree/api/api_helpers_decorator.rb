Spree::Api::ApiHelpers.module_eval do
  def stock_location_attributes_with_reserved_items_decoration
    stock_location_attributes_without_reserved_items_decoration | [:reserved_items]
  end

  alias_method_chain :stock_location_attributes, :reserved_items_decoration
end
