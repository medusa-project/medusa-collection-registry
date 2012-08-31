class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_logged_in
  before_filter :check_authorization
  helper_method :current_user, :logged_in?

  protected

  def set_current_user(user)
    @current_user = user
    session[:current_user_id] = user.id
  end

  def unset_current_user
    @current_user = nil
    session[:current_user_id] = nil
  end

  def current_user
    @current_user || User.find_by_id(session[:current_user_id])
  end

  def current_user_uid
    current_user.uid
  end

  def logged_in?
    current_user.present?
  end

  def require_logged_in
    redirect_to(login_path) unless logged_in?
  end

  if Rails.env == 'production'
    def check_authorization
      redirect_to(unauthorized_path) unless is_authorized?
    end
  else
    def check_authorization
      redirect_to(unauthorized_path) unless is_authorized_devel?
    end
  end

  #TODO make this use session information and LDAP lookup if needed from user uid
  def is_authorized?
    return true
  end

  #TODO make this work well for development/testing purposes
  def is_authorized_devel?
    case current_user_uid
      when /admin/
        return true
      when /visitor/
        return false
      else
        return false
    end
  end

end
