class User < ActiveRecord::Base
  has_many :cache_ldap_groups, :dependent => :destroy

  validates_uniqueness_of :uid, allow_blank: false
  validates_uniqueness_of :email, allow_blank: false

  def netid
    self.uid.split('@').first
  end

  def net_id
    self.netid
  end

  def person
    Person.find_or_create_by(net_id: self.uid)
  end

end
