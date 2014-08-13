class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    @current_user ||= OpenStruct.new(name: 'User Example', email: 'user@example.com')
  end
end
