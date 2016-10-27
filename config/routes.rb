Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reserved_stock_items, :except => [:show, :new, :edit]
    resources :users do
      resources :reserved_stock_items do
        member do
          post :restock
        end
      end
    end

  end
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :reserved_stock_items, only: :index do
        collection do
          post :reserve
          post :restock
          post :restock_expired
        end
      end
      resources :user do
        resources :reserved_stock_items, only: :index
      end
    end
  end
end
