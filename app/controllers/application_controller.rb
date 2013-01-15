require 'uiuc_ldap'
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_logged_in
  before_filter :authorize
  before_filter :log_session
  helper_method :current_user, :logged_in?

  protected

  def log_session
    Rails.logger.info("SESSION_DUMP")
    Rails.logger.info("#{self.controller_name}##{self.action_name}")
    Rails.logger.info(self.session.to_s)
  end

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

  def authorize
    authorize! :manage, MedusaRails3::Application
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to unauthorized_path
  end


  #TODO Possible problems:
  #- changes in LDAP won't be picked up right away if user already has session
  # (so must restart server or browser to ensure that they are or allow timeouts to take effect)
  #- things are still not really set up well if the call to the service fails. UiucLdap will
  #  raise an error, but then what?
  #- possibly more that I haven't thought of
  def self.is_member_of?(group, user, domain = 'uofi')
    permission = find_cached_permission(group, user, domain)
    if permission
      return permission.member
    else
      membership = UiucLdap.is_member_of?(group, user.uid, domain)
      self.cache_permission(user, group, domain, membership)
      return membership
    end
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
