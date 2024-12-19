class SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def new
    session[:login_return_referer] = request.env['HTTP_REFERER']
    if Rails.env.production? || Rails.env.demo?
      redirect_to(shibboleth_login_path(MedusaCollectionRegistry::Application.shibboleth_host))
    else
      redirect_to('/auth/identity')
    end
  end

  def create
    return_url = clear_and_return_return_path
    auth_hash = request.env['omniauth.auth']

    if Rails.env.production? || Rails.env.demo?
      # Handle Shibboleth login
      if auth_hash && auth_hash[:uid]
        user = User.find_or_create_by!(uid: auth_hash[:uid], email: auth_hash[:info][:email])
        reset_ldap_cache(user)
        set_current_user(user)
        redirect_to return_url
      else
        redirect_to login_url
      end
    else
      # Handle Developer strategy and Identity login
      if auth_hash && auth_hash[:provider] == 'developer'
        user = User.find_or_create_by!(uid: auth_hash[:uid], email: auth_hash[:info][:email])
        set_current_user(user)
        redirect_to return_url
      elsif params.has_key?("auth_key")
        user = User.find_or_create_by!(uid: params["auth_key"], email: params["auth_key"])
        set_current_user(user)
        redirect_to return_url
      else
        redirect_to login_url
      end
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

    return root_path unless (Rails.env.production? || Rails.env.demo?)

    return_url = session[:login_return_uri] || session[:login_return_referer] || root_path
    session[:login_return_uri] = session[:login_return_referer] = nil
    reset_ldap_cache(current_user)
    reset_session
    return_url
  end

  def shibboleth_login_path(host)
    "/Shibboleth.sso/Login?target=https://#{host}/auth/shibboleth/callback"
  end

end