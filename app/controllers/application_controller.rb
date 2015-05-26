class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  def require_login
	if current_user.nil?
		flash[:error] = "You are not permitted, please login first"
		redirect_to login_path
	else
		return current_user
	end
  end

  private
	  def current_user
	  	@current_user ||= User.find(session[:user]) if session[:user]
	  end

end
