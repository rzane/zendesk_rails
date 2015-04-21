require 'rubygems'
require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'active_model'
require 'combustion'
Combustion.initialize! :action_controller, :action_view, :sprockets

require 'zendesk_rails'
require 'rspec/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

Dir[ZendeskRails::Engine.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include ZendeskRails::Engine.routes.url_helpers
end
