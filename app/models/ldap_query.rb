require 'uri'
class LdapQuery < Object

  delegate :ldap_cache_key, to: :class

  def initialize

  end

  def is_member_of?(group, net_id)
    return false unless group.present?
    json = Rails.cache.fetch(ldap_cache_key(net_id)) do
      "{}"
    end
    hash = JSON.parse(json)
    if hash.has_key?(group)
      hash[group]
    else
      response = HTTParty.get(ldap_url(group, net_id))
      (response.success? and response.body == 'TRUE').tap do |is_member|
        hash[group] = is_member
        Rails.cache.write(ldap_cache_key(net_id), hash.to_json, expires_in: 1.day, race_condition_ttl: 10.seconds)
      end
    end
  end

  def ldap_url(group, net_id)
    "http://quest.grainger.uiuc.edu/directory/ad/#{net_id}/ismemberof/#{URI.encode(group)}"
  end

  def self.ldap_cache_key(net_id)
    "ldap_#{net_id}"
  end

  #Historically it was possible to delete a single user from the cache, but this isn't really
  # possible as things are now, so just blow away the whole cache.
  def self.reset_cache(net_id = nil)
    Rails.cache.delete(ldap_cache_key(net_id))
  end

end