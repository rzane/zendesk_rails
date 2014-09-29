class ZendeskRails::ApplicationController < ApplicationController
  layout :zendesk_layout

  helper_method :zendesk_current_user,
                :zendesk_user_signed_in?,
                :zendesk_user_attribute,
                :zendesk_unauthenticated_redirect_path

  def zendesk_current_user
    send "current_#{ZendeskRails.config.devise_scope}"
  end

  def zendesk_user_signed_in?
    send "#{ZendeskRails.config.devise_scope}_signed_in?"
  end

  def zendesk_user_attribute(attribute)
    attr_name = ZendeskRails.config.user_attributes[attribute]
    zendesk_current_user.try :send, attr_name
  end

  def zendesk_unauthenticated_redirect_path
    main_app.root_path
  end

  private

  def zendesk_layout
    ZendeskRails.config.layout
  end
end
