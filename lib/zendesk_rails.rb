require 'zendesk_rails/engine'

module ZendeskRails
  class << self
    attr_reader :config
    delegate :client, to: :config

    def configure(&block)
      @config = Configuration.new(&block)
      @config.client
    end
  end
end
