module UiucLdap
  class LDAPError < RuntimeError;
  end;

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


  #Prefer not to use this directly, but through ApplicationController.is_member_of?
  #which performs caching and has provision for testing, etc.
  def is_member_of?(group, net_id, domain=nil)
    return false if group.blank?
    is_member_of_ldap_group?(group, net_id, domain)
  end

end