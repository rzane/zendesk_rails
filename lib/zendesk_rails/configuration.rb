module ZendeskRails
  class Configuration
    CLIENT_OPTIONS = [
      :username,
      :password,
      :token,
      :url,
      :retry,
      :logger,
      :client_options,
      :adapter,
      :allow_http,
      :access_token,
      :url_based_access_token
    ]

    DEFAULT_SORTING = {
      sort_by: :created_at,
      sort_order: :desc
    }

    DEFAULT_USER_ATTRIBUTES = {
      name: :name,
      email: :email
    }

    attr_accessor *CLIENT_OPTIONS
    attr_accessor :layout
    attr_writer :devise_scope
    attr_writer :app_name
    attr_writer :time_formatter
    attr_writer :test_mode
    attr_writer :user_attributes
    attr_writer :ticket_list_options
    attr_writer :comment_list_options

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

    def ticket_list_options
      (@ticket_list_options || {}).reverse_merge(DEFAULT_SORTING)
    end

    def comment_list_options
      (@comment_list_options || {}).reverse_merge(DEFAULT_SORTING)
    end

    def build_client
      client_class.new do |client_config|
        CLIENT_OPTIONS.each do |opt|
          if value = send(opt)
            client_config.send("#{opt}=", value)
          end
        end
      end
    end

    private

    def client_class
      if test_mode?
        require 'zendesk_rails/testing'
        ZendeskRails::Testing::Client
      else
        ::ZendeskAPI::Client
      end
    end
  end
end
