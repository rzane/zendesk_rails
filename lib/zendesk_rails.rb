require 'zendesk_api'
require 'zendesk_rails/engine'
require 'zendesk_rails/configuration'

module ZendeskRails
  mattr_reader :config, :client

  def self.configure
    @@config = ZendeskRails::Configuration.new
    yield config
    @@client = config.build_client
  end
end
