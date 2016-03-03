Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    # create -> StockReserver#reserve
    namespace :reserved_stock_items do
      post :reserve
      post :restock
      post :restock_expired
    end
  end
end
