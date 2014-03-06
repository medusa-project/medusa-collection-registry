class User < ActiveRecord::Base
  has_many :cache_ldap_groups, :dependent => :destroy

  def netid
    self.uid.split('@').first
  end
  
end
