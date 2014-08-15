module ZendeskRailsHelper
  def configure(opts = {})
    ZendeskRails.configure do |config|
      opts.each do |key, value|
        config.send("#{key}=", value) if value
      end
    end
  end
end

RSpec.configure do |config|
  config.include ZendeskRailsHelper
end
