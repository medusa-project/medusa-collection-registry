module UiucLdap
  class LDAPError < RuntimeError ; end ;

  module_function

  LDAP_LOOKUP_BASE_URL = 'http://quest.grainger.uiuc.edu/directory'

  def is_member_of_ldap_group?(group, net_id, domain = nil)
    url_string = request_url(group, net_id, domain)
    url = URI.parse(url_string)
    request = Net::HTTP::Get.new(url.path)
    response = Net::HTTP.start(url.host, url.port) do |http|
      http.request(request)
    end
    if response.class == Net::HTTPOK
      response.body.downcase == 'true'
    else
      #problem fulfilling request
      raise LDAPError, "Could not look up for group #{group} and net id #{net_id}"
    end
  end

  def request_url(group, net_id, domain)
    parts = ['ad', 'ismemberof', domain, group, net_id].compact.collect { |p| encode(p.to_s) }
    "#{LDAP_LOOKUP_BASE_URL}/#{parts.join('/')}"
  end

  #The web service appears to care that %20 and not + is used for a space, so encode taking
  #that into account
  def encode(string)
    Rack::Utils.escape(string).gsub('+', '%20')
  end

  if Rails.env == 'production'
    def is_member_of?(group, net_id, domain=nil)
      return false if group.blank?
      is_member_of_ldap_group?(group, net_id, domain)
    end
  else
    #To make development/test easier
    #any net_id that matches admin is member
    #any net_id that matches visitor is a member only of 'Library Medusa Users'
    #any net_id that matches outsider is a member of no AD groups
    #otherwise member iff the part of the net_id preceding '@' (recall Omniauth dev mode uses email as uid)
    #includes the group when both are downcased and any spaces in the group converted to '-'
    def is_member_of?(group, net_id, domain=nil)
      return false if group.blank?
      return true if net_id.match(/admin/) and (group == 'Library Medusa Admins' or group == 'Library Medusa Users')
      return true if net_id.match(/manager/) and (group == 'Library Medusa Users' or group.match(/manager/))
      return true if net_id.match(/visitor/) and group == 'Library Medusa Users'
      return false if net_id.match(/visitor/) or net_id.match(/outsider/)
      return net_id.split('@').first.downcase.match(group.downcase.gsub(' ', '-'))
    end
  end

end