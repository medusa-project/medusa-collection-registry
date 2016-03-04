class GroupResolver::Test < GroupResolver::Base

  #To make development/test easier
  #any net_id that matches admin is member of the ad_admin and ad_users
  #any net_id that matches user is a member only of ad_users
  #any net_id that matched manager is a member of ad_users and the managers group
  #any net_id that matches outsider or visitor is a member of no AD groups, but is logged in
  #otherwise member iff the part of the net_id preceding '@' (recall Omniauth dev mode uses email as uid)
  #includes the group when both are downcased and any spaces in the group converted to '-'
  def is_member_of?(group, user)
    net_id = user.net_id rescue ''
    return false if group.blank?
    return true if net_id.match(/admin/) and (group == admin_ad_group or group == user_ad_group)
    return true if net_id.match(/manager/) and (group == user_ad_group or group.match(/manager/))
    return true if net_id.match(/user/) and group == user_ad_group
    return false if net_id.match(/user/) or net_id.match(/outsider/) or net_id.match(/visitor/)
    return net_id.split('@').first.downcase.match(group.downcase.gsub(' ', '-'))
  end

end