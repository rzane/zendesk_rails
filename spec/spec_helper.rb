require 'rubygems'
require 'bundler/setup'
require 'combustion'
Combustion.initialize! :action_controller, :action_view, :sprockets
require 'zendesk_rails'
require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
