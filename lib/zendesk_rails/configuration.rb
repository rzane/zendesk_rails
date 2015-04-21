module ZendeskRails
  class Configuration
    DEFAULT_SORTING = {
      sort_by: :created_at,
      sort_order: :desc
    }

    DEFAULT_USER_ATTRIBUTES = {
      name: :name,
      email: :email
    }

    attr_accessor :layout
    attr_writer :devise_scope
    attr_writer :app_name
    attr_writer :time_formatter
    attr_writer :test_mode
    attr_writer :user_attributes
    attr_writer :ticket_list_options
    attr_writer :comment_list_options
    attr_writer :ticket_create_params

    def initialize(&block)
      @zendesk_api_client = ZendeskAPI::Client.new do |config|
        @zendesk_api_config = config
        yield self
      end
    end

    def devise_scope
      @current_user_method || :user
    end

    def app_name
      @app_name || I18n.translate('zendesk.app_name')
    end

    def time_formatter
      @time_formatter || ->(time) { "#{time_ago_in_words(time)} ago" }
    end

    def test_mode?
      @test_mode
    end

    def user_attributes
      (@user_attributes || {}).reverse_merge(DEFAULT_USER_ATTRIBUTES)
    end

    def ticket_create_params
      @ticket_create_params || {}
    end

    def ticket_list_options
      (@ticket_list_options || {}).reverse_merge(DEFAULT_SORTING)
    end

    def comment_list_options
      (@comment_list_options || {}).reverse_merge(DEFAULT_SORTING)
    end

    def client
      @client ||= begin
        if test_mode?
          require 'zendesk_rails/testing'
          ZendeskRails::Testing::Client.new
        else
          @zendesk_api_client
        end
      end
    end

    def respond_to_missing?(meth, *)
      @zendesk_api_config.respond_to?(meth) || super
    end

    def method_missing(meth, *args, &block)
      if @zendesk_api_config.respond_to?(meth)
        @zendesk_api_config.send(meth, *args, &block)
      else
        super
      end
    end
  end
end
