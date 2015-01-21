require 'zendesk_rails/engine'

module ZendeskRails
  mattr_reader :config, :client

  def self.configure
    @@config = ZendeskRails::Configuration.new
    yield config
    @@client = config.build_client
  end
end
