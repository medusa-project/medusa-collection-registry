require 'uiuc_ldap'
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_logged_in
  before_filter :authorize
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
    redirect_to(login_path) unless logged_in?
  end

  def authorize
    authorize! :manage, MedusaRails3::Application
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to unauthorized_path
  end


  #TODO Figure out a reasonable way to cache here - maybe a DB level cache?
  #Possible problems:
  #- changes in LDAP won't be picked up right away if user already has session
  #(so must restart server or browser to ensure that they are)
  #- cache is local to rails instance, so still may need to do same lookup when user goes
  #  over to another passenger instance (solve with memcache?). This could be solved if I
  #  could get into the session, but I don't see any way to do this from the class side
  #  nor to get hold of the actual controller instance while in the auth process to do it
  #  from that side.
  #- things are still not really set up well if the call to the service fails. UiucLdap will
  #  raise an error, but then what?
  #- possibly more that I haven't thought of
  def self.is_member_of?(group, user, domain = nil)
    return UiucLdap.is_member_of?(group, user.uid, domain)
     #@ldap_cache ||= Hash.new
     #user_cache = (@ldap_cache[user.uid] ||= Hash.new)
     #if user_cache.has_key?(group)
     #  return user_cache[group]
     #else
     #  membership = UiucLdap.is_member_of?(group, user.uid, domain)
     #  user_cache[group] = membership
     #  return membership
     #end
   end

   def self.clear_ldap_cache(user)
     @ldap_cache ||= Hash.new
     @ldap_cache[user.uid] = {}
   end

end
