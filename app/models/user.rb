class User < ActiveRecord::Base
  has_many :cache_ldap_groups, :dependent => :destroy

  def netid
    self.uid.split('@').first
  end

  def person
    Person.find_or_create_by(net_id: self.netid)
  end

end
