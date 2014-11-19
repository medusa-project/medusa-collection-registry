class SessionsController < ApplicationController

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
    #auth_hash[:uid] should have the uid (for shib as configured in shibboleth.yml)
    #auth_hash[:info][:email] should have the email address
    auth_hash = request.env['omniauth.auth']
    if auth_hash and auth_hash[:uid]
      return_url = clear_and_return_return_path
      user = User.find_or_create_by!(uid: auth_hash[:uid], email: auth_hash[:info][:email])
      reset_ldap_cache(user)
      if ApplicationController.is_ad_user?(user)
        set_current_user(user)
        #We can access other information via auth_hash[:extra][:raw_info][key]
        #where key is a string from config/shibboleth.yml (and of course these
        #have to correspond to passed attributes) One idea is to stuff them
        #into the session hash at this point and then have them available if needed
        #elsewhere.
        redirect_to return_url
      else
        redirect_to unauthorized_net_id_url(net_id: user.net_id)
      end
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

  def unauthorized_net_id
    @net_id = params[:net_id]
  end

  protected

  def clear_and_return_return_path
    return_url = session[:login_return_uri] || session[:login_return_referer] || root_path
    session[:login_return_uri] = session[:login_return_referer] = nil
    reset_ldap_cache(current_user)
    reset_session
    return_url
  end

end