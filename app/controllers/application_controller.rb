class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_logged_in

  protected

  def set_current_user(user)
    @current_user = user
    session[:current_user_id] = user.id
  end

  def current_user
    @current_user || User.find_by_id(session[:current_user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_logged_in
    redirect_to(login_path) unless logged_in?
  end

end
