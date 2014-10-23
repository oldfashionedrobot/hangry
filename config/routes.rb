Rails.application.routes.draw do
  get '/restaurants/pick', to: 'restaurants#pick'
  resources :restaurants

  root to: 'application#index'
end
