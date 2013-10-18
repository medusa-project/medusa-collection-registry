class User < ActiveRecord::Base
  has_many :cache_ldap_groups, :dependent => :destroy
end
