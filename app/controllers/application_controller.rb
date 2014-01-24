require 'uiuc_ldap'
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :logged_in?

  protected

  def set_current_user(user)
    @current_user = user
    self.class.clear_ldap_cache(user)
    session[:current_user_id] = user.id
  end

  def unset_current_user
    self.class.clear_ldap_cache(current_user)
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
    unless logged_in?
      session[:login_return_uri] = request.env['REQUEST_URI']
      redirect_to(login_path)
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to unauthorized_path
  end

  def record_event(eventable, key, user = current_user)
    eventable.events.create(:actor_netid => user.uid, :key => key, :date => Date.today)
  end


  #TODO Possible problems:
  #- changes in LDAP won't be picked up right away if user already has session
  # (so must restart server or browser to ensure that they are or allow timeouts to take effect)
  #- things are still not really set up well if the call to the service fails. UiucLdap will
  #  raise an error, but then what?
  #- possibly more that I haven't thought of
  def self.is_member_of?(group, user, domain = nil)
    domain = 'uofi' if domain.blank?
    return UiucLdap.is_member_of?(group, user.uid, domain)
  end

  #see if there is a cached permission that hasn't timed out. If so, return. If there is one that needs timing out
  #do it. If there is not one then return false.
  #In fact for now we time out everything that needs timing out at this point.
  def self.find_cached_permission(group, user, domain = 'uofi')
    permission = user.cache_ldap_groups.where(:group => group).where(:domain => domain).first
    if permission
      cutoff_time = Time.now - 10.minutes
      if cutoff_time > permission.created_at
        CacheLdapGroup.where("created_at < ?", cutoff_time).delete_all
        return false
      else
        return permission
      end
    else
      return false
    end
  end

  def self.cache_permission(user, group, domain, membership)
    user.cache_ldap_groups.create(:group => group, :domain => domain, :member => membership)
  end

  def self.clear_ldap_cache(user)
    user.cache_ldap_groups.clear
  end

end
