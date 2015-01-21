module ZendeskRails
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      delegate :config, to: :ZendeskRails, prefix: :zendesk
      delegate :layout, to: :zendesk_config, prefix: :zendesk

      helper_method :zendesk_config,
                    :zendesk_current_user,
                    :zendesk_user_signed_in?,
                    :zendesk_user_attribute
    end

    def zendesk_current_user
      send "current_#{zendesk_config.devise_scope}"
    end

    def zendesk_user_signed_in?
      send "#{zendesk_config.devise_scope}_signed_in?"
    end

    # Gets the value of a user's name/emails based on
    # configurable attribute names
    def zendesk_user_attribute(attribute)
      attr_name = zendesk_config.user_attributes[attribute]
      zendesk_current_user.try(attr_name)
    end

    # The user will be redirected to this URL when a
    # ticket is successfully created
    def after_zendesk_ticket_created_path_for(ticket)
      ticket_path(ticket.id)
    end

    # Render will be called with these arguments when a ticket is invalid
    def after_zendesk_ticket_invalid_template
      'new'
    end
  end
end
