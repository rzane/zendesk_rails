require 'rubygems'
require 'bundler'
require 'rails'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'jquery/rails'
require 'combustion'

Combustion.initialize! :action_controller, :action_view, :sprockets
run Combustion::Application
