class SessionsController < ApplicationController

  skip_before_filter :require_logged_in
  skip_before_filter :authorize
  skip_before_filter :verify_authenticity_token

  def new
    session[:login_return_referer] = request.env['HTTP_REFERER']
    if Rails.env.production?
      redirect_to(OmniAuth::Strategies::Shibboleth.login_path(MedusaRails3::Application.shibboleth_host))
    else
      redirect_to('/auth/developer')
    end
  end

  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash and auth_hash[:uid] then
      return_url = clear_and_return_return_path
      set_current_user(User.find_or_create_by(uid: auth_hash[:uid]))
      #We can access other information via auth_hash[:extra][:raw_info][key]
      #where key is a string from config/shibboleth.yml (and of course these
      #have to correspond to passed attributes) One idea is to stuff them
      #into the session hash at this point and then have them available if needed
      #elsewhere.
      redirect_to return_url
    else
      redirect_to login_url
    end
  end

  def destroy
    unset_current_user
    clear_and_return_return_path
    redirect_to root_url
  end

  def unauthorized

  end

  protected

  def clear_and_return_return_path
    return_url = session[:login_return_uri] || session[:login_return_referer] || root_path
    session[:login_return_uri] = session[:login_return_referer] = nil
    reset_session
    return_url
  end

end