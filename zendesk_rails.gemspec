$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'zendesk_rails/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'zendesk_rails'
  s.version     = ZendeskRails::VERSION
  s.authors     = ['Ray Zane']
  s.email       = ['raymondzane@gmail.com']
  s.homepage    = 'https://github.com/rzane/zendesk_rails'
  s.summary     = 'Rails Help Desk Ticketing using the Zendesk API'
  s.description = 'A Rails engine to add help desk ticketing using the Zendesk API.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '>= 4.0'
  s.add_dependency 'zendesk_api'
  s.add_dependency 'jquery-rails'

  s.add_development_dependency 'combustion', '~> 0.5.2'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
end
