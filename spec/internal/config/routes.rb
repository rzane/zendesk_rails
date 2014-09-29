Rails.application.routes.draw do
  mount ZendeskRails::Engine, at: '/'
  root to: 'tickets#index'
end
