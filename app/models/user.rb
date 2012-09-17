class User < ActiveRecord::Base
  attr_accessible :uid
  has_many :cache_ldap_groups, :dependent => :destroy
end
