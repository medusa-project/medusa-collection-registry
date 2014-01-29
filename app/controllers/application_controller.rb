require 'uiuc_ldap'
class ApplicationController < ActionController::Base
  protect_from_forgery
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


  #We cache the results in sessions. Since these are stored server
  #side I don't think there will be a problem.
  def self.is_member_of?(group, user, domain = nil)
    domain = 'uofi' if domain.blank?
    #check cache
    cached_value = self.cached_ldap_value(user, group, domain)
    return cached_value unless cached_value.nil?
    #if not in cache then lookup, cache, and return
    UiucLdap.is_member_of?(group, user.uid, domain).tap do |permitted|
      self.cache_ldap_value(user, group, domain, permitted)
    end
  end

  def reset_ldap_cache(user)
    user ||= current_user
    if user
      Rails.cache.write(ldap_cache_key(user), Hash.new)
    end
  end

  def self.cached_ldap_value(user, group, domain)
    hash = Rails.cache.read(ldap_cache_key(user)) || Hash.new
    hash[[group, domain]]
  end

  def self.cache_ldap_value(user, group, domain, permitted)
    hash = Rails.cache.read(ldap_cache_key(user)) || Hash.new
    hash[[group, domain]] = permitted
    Rails.cache.write(ldap_cache_key(user), hash, expires_in: 2.hours)
  end

  def self.ldap_cache_key(user)
    "ldap_#{user.id}"
  end

  def ldap_cache_key(user)
    self.class.ldap_cache_key(user)
  end

end
