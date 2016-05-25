object false
child(@reserved_stock_items => :reserved_stock_items) do
  extends 'spree/api/v1/reserved_stock_items/show'
end
node(:count) { @reserved_stock_items.count }
node(:current_page) { params[:page] || 1 }
node(:pages) { @reserved_stock_items.num_pages }
