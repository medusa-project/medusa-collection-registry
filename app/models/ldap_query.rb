class LdapQuery < Object

  attr_accessor :host, :port, :protocol, :user, :passwd, :base, :search,
                :connection

  def initialize
    config = MedusaCollectionRegistry::Application.medusa_config['ldap']
    self.host = config['host']
    self.port = config['port']
    self.protocol = config['protocol']
    self.user = config['user']
    self.passwd = config['passwd']
    self.base = config['base']
    self.search = config['search']
    self.connect
  end

  def is_member_of?(group, net_id)
    cached_groups(net_id).include?(group)
  end

  def groups(net_id, memberships = nil)
    memberships ||= Set.new
    filter = Net::LDAP::Filter.eq('cn', net_id)
    connection.search(base: base, filter: filter) do |entry|
      entry[:memberOf].each do |group|
        group.scan(/#{search}/) do |m|
          g = m[0]
          unless memberships.include?(g)
            memberships << g
            groups(g, memberships)
          end
        end
      end
    end
    memberships
  end

  def cached_groups(net_id)
    cache = Rails.cache.read(ldap_cache_key(net_id))
    return cache if cache.present?
    groups(net_id).tap do |memberships|
      Rails.cache.write(ldap_cache_key(net_id), memberships)
    end
  end

  def ldap_cache_key(net_id)
    "ldap_groups_#{net_id}"
  end

  def connect
    self.connection = Net::LDAP.new(host: host, port: port, encryption: :start_tls,
                                    auth: {username: user, password: passwd, method: :simple})
    unless connection.bind
      raise RuntimeError, "Unable to connect to LDAP server"
    end
  end

end