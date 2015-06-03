class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    if user_signed_in?
      OpenStruct.new(name: 'User Example', email: 'user@example.com')
    end
  end

  def user_signed_in?
    !ENV['UNAUTHENTICATED']
  end
end
