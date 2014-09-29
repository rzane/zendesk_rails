module ZendeskRailsHelper
  def configure(opts = {})
    ZendeskRails.configure do |config|
      opts.each do |key, value|
        config.send("#{key}=", value) if value
      end
    end
  end

  def sign_in(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user) { user }
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?) { true }
  end

  def sign_out
    allow_any_instance_of(ApplicationController).to receive(:current_user) { nil }
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?) { false }
  end
end

RSpec.configure do |config|
  config.include ZendeskRailsHelper
end
