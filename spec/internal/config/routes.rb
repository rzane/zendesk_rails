Rails.application.routes.draw do
  mount ZendeskRails::Engine, at: '/'
end
