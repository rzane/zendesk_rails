require 'zendesk_api'
require 'zendesk_rails/configuration'
require 'zendesk_rails/controller_helpers'

module ZendeskRails
  class Engine < ::Rails::Engine
    isolate_namespace ZendeskRails

    initializer "zendesk_rails.helpers" do
      ActiveSupport.on_load(:action_controller) do
        include ZendeskRails::ControllerHelpers
      end
    end
  end
end
