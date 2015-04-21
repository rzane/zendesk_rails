require 'zendesk_api'
require 'zendesk_rails/configuration'

module ZendeskRails
  class Engine < ::Rails::Engine
    isolate_namespace ZendeskRails
  end
end
