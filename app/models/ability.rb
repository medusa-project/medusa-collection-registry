require 'uiuc_ldap' #we may not need this here, but this will ensure it is available for anything  that needs it
class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, AccessSystem if medusa_admin?(user)
  end

  def medusa_admin?(user)
    ApplicationController.is_member_of?('Library Medusa Admins', user, 'uofi')
  end

end
