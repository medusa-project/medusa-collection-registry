require 'uiuc_ldap' #we may not need this here, but this will ensure it is available for anything  that needs it
class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, AccessSystem if medusa_admin?(user)
    #Assessments - must be done for each assessable, where the real check occurs
    [Collection, FileGroup, ExternalFileGroup, BitLevelFileGroup, ObjectLevelFileGroup, Repository].each do |klass|
      can :destroy_assessment, klass if medusa_admin?(user)
      can [:create_assessment, :update_assessment], klass do |assessable|
        medusa_admin?(user) ||
            (assessable.is_a?(klass) and repository_manager?(user, assessable))
      end
    end
    #Attachments - must be done for each attachable, where the real check occurs
    [Collection].each do |klass|
      can :destroy_attachment, klass if medusa_admin?(user)
      can [:create_attachment, :update_attachment], klass do |attachable|
        medusa_admin?(user) ||
            (attachable.is_a?(klass) and repository_manager?(user, attachable))
      end
    end
  end

  def medusa_admin?(user)
    ApplicationController.is_member_of?('Library Medusa Admins', user, 'uofi')
  end

  def repository_manager?(user, object)
    object.repository.manager?(user)
  end

end
