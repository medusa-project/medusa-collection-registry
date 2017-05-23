class GroupResolver::Base < Object

  def user_ad_group
    Settings.medusa.medusa_users_group
  end

  def admin_ad_group
    Settings.medusa.medusa_admins_group
  end

  def project_admin_ad_group
    Settings.medusa.medusa_project_admins_group
  end

  def superuser_ad_group
    Settings.medusa.medusa_superusers_group
  end

  def is_ad_user?(user)
    user and is_member_of?(user_ad_group, user)
  end

  def is_project_admin?(user)
    user and is_member_of?(project_admin_ad_group, user)
  end

  def is_ad_admin?(user)
    user and is_member_of?(admin_ad_group, user)
  end

  def is_ad_superuser?(user)
    user and is_member_of?(superuser_ad_group, user)
  end

  def is_member_of?(ad_group, user)
    raise RuntimeError, 'Subclass responsibility'
  end

end