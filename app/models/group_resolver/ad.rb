class GroupResolver::Ad < GroupResolver::Base

  def is_member_of?(group, user)
    net_id = user.net_id rescue ''
    LdapQuery.new.is_member_of?(group, net_id)
  end

end