ZendeskRails::Engine.routes.draw do
  resources :tickets
  root to: 'tickets#index'
end
