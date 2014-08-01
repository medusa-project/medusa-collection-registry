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

  def require_logged_in_or_basic_auth
    unless logged_in? or basic_auth?
      session[:login_return_uri] = request.env['REQUEST_URI']
      redirect_to(login_path)
    end
  end

  def basic_auth?
    ActionController::HttpAuthentication::Basic.decode_credentials(request) == MedusaRails3::Application.medusa_config['basic_auth']
  rescue
    false
  end

  rescue_from CanCan::AccessDenied do
    redirect_to unauthorized_path
  end

  def record_event(eventable, key, user = current_user)
    eventable.events.create(:actor_email => user.email, :key => key, :date => Date.today)
  end


  #We cache the results in sessions. Since these are stored server
  #side I don't think there will be a problem.
  def self.is_member_of?(group, user, domain = nil)
    domain = 'uofi' if domain.blank?
    #check cache
    cached_value = self.cached_ldap_value(user, group, domain)
    return cached_value unless cached_value.nil?
    #if not in cache then lookup, cache, and return
    self.internal_is_member_of?(group, user.net_id, domain).tap do |permitted|
      self.cache_ldap_value(user, group, domain, permitted)
    end
  end

  #We define this differently for production and development/test for convenience
  if Rails.env.production?
    def self.internal_is_member_of?(group, net_id, domain)
      UiucLdap.is_member_of?(group, net_id, domain)
    end
  else
    #To make development/test easier
    #any net_id that matches admin is member of the ad_admin and ad_users
    #any net_id that matches visitor is a member only of ad_users
    #any net_id that matched manager is a member of ad_users and the managers group
    #any net_id that matches outsider is a member of no AD groups
    #otherwise member iff the part of the net_id preceding '@' (recall Omniauth dev mode uses email as uid)
    #includes the group when both are downcased and any spaces in the group converted to '-'
    def self.internal_is_member_of?(group, net_id, domain=nil)
      return false if group.blank?
      return true if net_id.match(/admin/) and (group == admin_ad_group or group == user_ad_group)
      return true if net_id.match(/manager/) and (group == user_ad_group or group.match(/manager/))
      return true if net_id.match(/visitor/) and group == user_ad_group
      return false if net_id.match(/visitor/) or net_id.match(/outsider/)
      return net_id.split('@').first.downcase.match(group.downcase.gsub(' ', '-'))
    end
  end

  def self.is_ad_user?(user)
    self.is_member_of?(user_ad_group, user, 'uofi')
  end

  def self.is_ad_admin?(user)
    self.is_member_of?(admin_ad_group, user, 'uofi')
  end

  def self.user_ad_group
    MedusaRails3::Application.medusa_config['medusa_users_group']
  end

  def self.admin_ad_group
    MedusaRails3::Application.medusa_config['medusa_admins_group']
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
