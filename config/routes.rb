Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :confirmation, only: :create, controller: "confirmations"
  get "confirmations/:token", to: "confirmations#show", as: :confirmation_token
  match "/auth/:provider/callback", to: "sessions#google", via: %i[ get post ]
  get "/auth/failure", to: "sessions#failure"
  resources :listings do
    collection do
      get :mine
      get :filter
      get :suggestions
      post :generate_description
    end
    resources :bids, only: :create
  end
  resources :bids, only: [] do
    member do
      patch :accept
      patch :reject
      patch :counter
    end
  end
  resources :hidden_listings, only: %i[ create destroy ], param: :listing_id
  resources :favorites, only: %i[ index create destroy ], param: :listing_id
  resource :profile, only: %i[ show update ]
  # Allow full CRUD for users so system tests and app pages can access index/show/edit/update/destroy
  resources :users, only: %i[ new create destroy ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker.js" => "rails/pwa#service_worker", as: :pwa_service_worker, defaults: { format: :js }
  get "manifest.json" => "rails/pwa#manifest", as: :pwa_manifest, defaults: { format: :json }

  # Defines the root path route ("/")
  # root "posts#index"
  root "listings#index"
end
