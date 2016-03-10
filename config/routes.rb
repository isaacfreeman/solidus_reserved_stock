Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :reserved_stock_items, :except => [:show, :new, :edit]
    resources :users do
      member do
        get :reserved_stock_items
      end
    end
  end
  namespace :api, defaults: { format: 'json' } do
    # create -> StockReserver#reserve
    namespace :reserved_stock_items do
      post :reserve
      post :restock
      post :restock_expired
    end
  end
end
