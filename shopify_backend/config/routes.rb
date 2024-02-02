Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :items, only: [:index, :create, :update, :destroy]

  match '*path', to: 'application#cors_preflight_check', via: [:options]
  get "articles" => "articles#index"
end
