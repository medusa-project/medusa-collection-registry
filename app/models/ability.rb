class Ability
  include CanCan::Ability

  def initialize(user)
    #medusa admins can do anything
    can :manage, :all if medusa_admin?(user)
    #Assessments - must be done for each assessable, where the real check occurs
    [Collection, FileGroup, ExternalFileGroup, BitLevelFileGroup, ObjectLevelFileGroup, Repository].each do |klass|
      can [:create_assessment, :update_assessment], klass do |assessable|
        (assessable.is_a?(klass) and repository_manager?(user, assessable))
      end
    end
    #Attachments - must be done for each attachable, where the real check occurs
    [Collection, FileGroup, BitLevelFileGroup, ObjectLevelFileGroup, ExternalFileGroup, Project].each do |klass|
      can [:create_attachment, :update_attachment], klass do |attachable|
        (attachable.is_a?(klass) and repository_manager?(user, attachable))
      end
    end
    #Cfs controller - need to see if requested path belongs to a file group managed by user
    #The FitsRequest object is a helper for this
    can :create_fits, FitsRequest do |request|
      repository_manager?(user, request)
    end
    can [:update, :create], Collection do |collection|
      repository_manager?(user, collection)
    end
    can [:create, :update, :edit_item, :create_item, :delete_item], Project do |project|
      repository_manager?(user, project)
    end
    #Events - must be done for each eventable, where the real check occurs
    [FileGroup, BitLevelFileGroup, ObjectLevelFileGroup, ExternalFileGroup].each do |klass|
      can [:create_event, :delete_event, :update_event], klass do |eventable|
        repository_manager?(user, eventable)
      end
    end
    #File groups - do for all subclasses, though I'm not sure this is strictly necessary
    [FileGroup, BitLevelFileGroup, ObjectLevelFileGroup, ExternalFileGroup].each do |klass|
      can [:update, :create, :create_cfs_fits, :create_virus_scan, :download, :export, :destroy], klass do |file_group|
        repository_manager?(user, file_group)
      end
    end
    can :update, RedFlag do |red_flag|
      repository_manager?(user, red_flag)
    end
    can :update, Repository do |repository|
      repository_manager?(user, repository)
    end
    can :manage, VirtualRepository do |virtual_repository|
      repository_manager?(user, virtual_repository.repository)
    end
    can :accrue, CfsDirectory do |directory|
      repository_manager?(user, directory)
    end
    can [:create_file_format_test, :update_file_format_test, :create_file_format_test_reason], CfsFile do |cfs_file|
      repository_manager?(user, cfs_file)
    end
    cannot [:decide], Workflow::FileGroupDelete do |workflow|
      !user.superuser?
    end
  end

  def medusa_admin?(user)
    Application.group_resolver.is_ad_admin?(user)
  end

  def repository_manager?(user, object)
    repository = object.repository
    repository and repository.manager?(user)
  end

end
