# Zendesk Rails

Zendesk Rails is a mountable engine for end-users to create, track, and comment on tickets. It uses the [Zendesk API Client](https://github.com/zendesk/zendesk_api_client_rb).

## Installation

Add `zendesk_rails` to your Gemfile.

```ruby
gem 'zendesk_rails'
```

## Setup

Mount the engine within your Rails application by adding this line to `config/routes.rb`.

```ruby
mount ZendeskRails::Engine, at: '/help'
```

Then you'll need to configure a few settings by creating an initializer.

```ruby
ZendeskRails.configure do
  config.url = 'https://example.zendesk.com/api/v2'

  # Basic / Token authentication
  config.username = 'user@example.com'

  # Choose one of the following depending on your authentication choice
  config.token = 'your zendesk token'
  config.password = 'your zendesk password'
end
```

You should be ready to go! Fire up your server and visit '/help'.

## Additional Configuration

#### Zendesk API Settings

The `configure` block accepts all settings from the [Zendesk API Client](https://github.com/zendesk/zendesk_api_client_rb). Take a look at their documentation for some additional configuration options.

#### Customization

##### config.app_name

Sets the name of the app in the navbar.

```ruby
config.app_name = 'My Application'
```

##### config.layout

Sets the path to a custom layout.

```ruby
config.layout = 'layouts/application'
```

##### config.devise_scope

By default, Zendesk Rails assumes your controller has a `current_user` method. If `config.devise_scope` were set to `:admin`, Zendesk Rails would use `current_admin`.

##### config.user_attributes

Your user model is expected to have `:name` and `:email` methods. Otherwise, you'll need to provide a hash with the values being the actual names of your methods.

```ruby
config.user_attributes = { name: :full_name, email: :email_address }
```

##### config.time_formatter

Times are displayed using `time_ago_in_words`. You can set this to either a string to be passed to `strftime`, or a proc that accepts a Time. Passing a proc allows you to use view helper methods.

```ruby
config.time_formatter = ->(time){ time.to_formatted_s }
```

##### config.ticket_list_options

Ticket list options are passed to the Zendesk API's search endpoint. By default, tickets are sorted by the created_at time in descending order.

```ruby
config.ticket_list_options = {
  sort_by: :created_at,
  sort_order: :desc
}
```

See http://developer.zendesk.com/documentation/rest_api/search.html

##### config.comment_list_options

Comment list options are passed to the Zendesk API's request comments. By default, comments are sorted by the created_at time in descending order.

```ruby
config.comment_list_options = {
  sort_by: :created_at,
  sort_order: :desc
}
```

See http://developer.zendesk.com/documentation/rest_api/requests.html#listing-comments

##### config.test_mode

When `config.test_mode` is true, a fake API will be used. All created tickets will be stored in memory. This setting is particularly useful for testing out Zendesk Rails. Do not use this setting in production.

### Overriding Controller Behavior

Zendesk Rails offers hooks that allow you to control what happens after a ticket is created/updated/invalid. To do that, create `app/controllers/zendesk_rails/tickets_controller.rb`.

```ruby
module ZendeskRails
  class TicketsController < ApplicationController
    private

    def after_created_ticket ticket # When a ticket is created
      redirect_to ticket_path(ticket.id), flash: { notice: 'Congrats!' }
    end

    def after_invalid_ticket ticket # When a ticket is invalid
      render 'new'
    end

    def after_updated_ticket ticket # When a comment is added
      redirect_to ticket_path(ticket.id), flash: { notice: 'Cool comment, bro.' }
    end
  end
end
```

### Overriding Content

Zendesk Rails allows you to easily override content using I18n. Override keys from [config/locales/zendesk_rails.yml](config/locales/zendesk_rails.yml) in a file located in your `config/locales` directory.
