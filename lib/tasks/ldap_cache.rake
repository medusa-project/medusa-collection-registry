require 'rake'

desc 'Clear all existing cached LDAP group memberships'
task clear_ldap_cache: :environment do
  CacheLdapGroup.delete_all
end