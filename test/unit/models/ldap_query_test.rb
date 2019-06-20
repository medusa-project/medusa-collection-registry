#Note that this runs against the live server, so is subject to such
# vagaries, and also uses real information so may need adjustment
# on that account,.
require 'test_helper'

class LdapQueryTest < ActiveSupport::TestCase

  test 'campus ldap lookups' do
    LdapQuery.reset_cache('hding2')
    ldap = LdapQuery.new
    assert ldap.is_member_of?('UIUC Campus Accounts Staff', 'hding2')
    refute ldap.is_member_of?('UIUC Campus Accounts Faculty', 'hding2')
    #Do it again to hit the cache
    refute ldap.is_member_of?('UIUC Campus Accounts Faculty', 'hding2')
  end

end