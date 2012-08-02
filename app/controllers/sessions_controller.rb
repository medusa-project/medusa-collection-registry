class SessionsController < ApplicationController

  skip_before_filter :require_logged_in

  def new
    if Rails.env.production?
      redirect_to('/auth/shibboleth')
    else
      redirect_to('/auth/developer')
    end
  end

  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash and auth_hash[:uid] then
      set_current_user(User.find_or_create_by_uid(auth_hash[:uid]))
      redirect_to root_path
    else
      redirect_to login_path
    end
  end

  def destroy
    unset_current_user
    redirect_to login_path
  end
end