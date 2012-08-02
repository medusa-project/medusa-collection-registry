class SessionsController < ApplicationController

  skip_before_filter :require_logged_in

  def new
    if Rails.env.production?
      redirect_to(OmniAuth::Strategies::Shibboleth.login_path(MedusaRails3::Application.shibboleth_host))
    else
      redirect_to('/auth/developer')
    end
  end

  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash and auth_hash[:uid] then
      set_current_user(User.find_or_create_by_uid(auth_hash[:uid]))
      #We can access other information via auth_hash[:extra][:raw_info][key]
      #where key is a string from config/shibboleth.yml (and of course these
      #have to correspond to passed attributes)
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