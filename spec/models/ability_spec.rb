# spec/models/ability_spec.rb
require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { Ability.new(user) }

  let(:repository) { create(:repository) }
  let(:collection) { create(:collection, repository: repository) }
  let(:file_group) { create(:file_group, collection: collection) }
  let(:cfs_directory) { create(:cfs_directory, parent: file_group) }
  let(:cfs_file) { create(:cfs_file, cfs_directory: cfs_directory) }

  let(:manager) { create(:person, email: user.email) }
  let(:project) { create(:project, collection: collection, manager: manager) }
  let(:permissible_collection) { create(:collection, repository: repository) }
  let(:non_permissible_collection) { create(:collection, repository: repository) }
  let(:producer) { create(:producer) }
  let(:virtual_repository) { create(:virtual_repository, repository: repository) }

  let(:file_group) { create(:file_group, collection: permissible_collection) }
  let(:another_file_group) { create(:file_group, collection: non_permissible_collection) }
  let(:workflow) { double('Workflow::FileGroupDelete') }

  before do
    # Prevent external Solr calls during tests
    allow(MedusaUuid).to receive(:generate_for).and_return(nil)
  end

  context 'when user is a medusa_admin' do
    let(:user) { create(:user) }
    before do
      allow(user).to receive(:medusa_admin?).and_return(true)
    end
    
    it 'can manage all resources' do
      expect(ability).to be_able_to(:manage, :all)
    end
  end
 
  context 'when user is a repository_manager' do
    let(:user) { create(:user, :repository_manager, repository: repository) }

    before do
      # Stub the manager? method for the repository
      allow(repository).to receive(:manager?).with(user).and_return(true)
    end

    it 'allows the user to create and update collections' do
      expect(repository.manager?(user)).to eq(true)
      expect(ability).to be_able_to(:create, collection)
      expect(ability).to be_able_to(:update, collection)
    end
  
    it 'can create and update assessments for collections' do
      expect(ability).to be_able_to(:create_assessment, collection)
      expect(ability).to be_able_to(:update_assessment, collection)
    end

    it 'can manage file groups' do
      expect(ability).to be_able_to(:update, file_group)
      expect(ability).to be_able_to(:create_event, file_group)
    end

    it 'cannot destroy projects' do
      expect(ability).not_to be_able_to(:destroy, project)
    end
  end

  
  context 'when user is a project_admin' do
    let(:user) { create(:user, :project_admin) }

    it 'can create, update, and destroy attachments in projects' do
      expect(ability).to be_able_to(:create_attachment, project)
      expect(ability).to be_able_to(:update_attachment, project)
      expect(ability).to be_able_to(:destroy_attachment, project)
    end

    it 'cannot manage collections or file groups' do
      expect(ability).not_to be_able_to(:manage, collection)
      expect(ability).not_to be_able_to(:manage, file_group)
    end
  end

  context 'when user is a repository manager' do
    let(:user) { create(:user, :repository_manager, repository: repository) }

    before do
      allow(repository).to receive(:manager?).with(user).and_return(true)
    end

    it 'can download files from any collection in the repository' do
      expect(ability).to be_able_to(:download, file_group)
      expect(ability).to be_able_to(:download, another_file_group)
    end
  end

  context 'when user is neither a downloader nor a repository manager' do
    let(:user) { FactoryBot.create(:user, email: 'projectadmin@illinois.edu', uid: 'projectadmin@illinois.edu') }
    
    before do
      allow_any_instance_of(Ability).to receive(:repository_manager?).and_return(false)
      allow_any_instance_of(Ability).to receive(:downloader?).and_return(false)
      allow(Settings).to receive(:download_users).and_return({})
    end

    it 'cannot download files from any collection' do
      expect(ability).not_to be_able_to(:download, file_group)
      expect(ability).not_to be_able_to(:download, another_file_group)
    end
  end
  
  context 'when user is a regular user' do
    let(:user) { create(:user) }

    before do
      allow(user).to receive(:project_admin?).and_return(false)
      allow(user).to receive(:medusa_admin?).and_return(false)
      allow(user).to receive(:superuser?).and_return(false)
    end

    it 'cannot manage any resources' do
      expect(ability).not_to be_able_to(:manage, :all)
    end

    it 'cannot manage events for file groups' do
      allow(repository).to receive(:manager?).with(user).and_return(false)
    
      # Ensure the user cannot manage events
      expect(ability).not_to be_able_to(:create_event, file_group)
      expect(ability).not_to be_able_to(:destroy_event, file_group)
      expect(ability).not_to be_able_to(:update_event, file_group)
    end
  end

  context 'when user is a public user' do
    let(:user) { nil } # unauthenticated public user

    it 'denies edit, update, delete, and view permissions for the producer' do
      expect(ability).not_to be_able_to(:edit, producer)
      expect(ability).not_to be_able_to(:update, producer)
      expect(ability).not_to be_able_to(:delete, producer)
      expect(ability).not_to be_able_to(:view, producer)
    end

    it 'denies new, create, and view_index permissions for producer collection' do
      expect(ability).not_to be_able_to(:new, Producer)
      expect(ability).not_to be_able_to(:create, Producer)
      expect(ability).not_to be_able_to(:view_index, Producer)
    end
  end

  context 'when user is a manager' do
    let(:user) { create(:user, :repository_manager) }
    
    before do
      allow(repository).to receive(:manager?).with(user).and_return(true)
    end

    it 'denies edit permission on the producer' do
      expect(ability).not_to be_able_to(:edit, producer)
    end

    it 'denies new and create permissions on the producer collection' do
      expect(ability).not_to be_able_to(:new, Producer)
      expect(ability).not_to be_able_to(:create, Producer)
    end
  end

  context 'when user is authenticated but not a manager' do
    let(:user) { create(:user, :repository_manager) }

    before do
      allow(repository).to receive(:manager?).with(user).and_return(false)
    end

    it 'denies edit, update, delete, and view permissions for the producer' do
      expect(ability).not_to be_able_to(:edit, producer)
      expect(ability).not_to be_able_to(:update, producer)
      expect(ability).not_to be_able_to(:delete, producer)
      expect(ability).not_to be_able_to(:view, producer)
    end

    it 'denies new and create permissions on the producer collection' do
      expect(ability).not_to be_able_to(:new, Producer)
      expect(ability).not_to be_able_to(:create, Producer)
    end
  end

  context 'when user is associated with specific permissions' do
    let(:user) { create(:user, :repository_manager, repository: repository) }

    it 'can manage virtual repositories if they manage the underlying repository' do
      expect(ability).to be_able_to(:manage, virtual_repository)
    end

    it 'can accrue CfsDirectory if they manage the directory' do
      expect(ability).to be_able_to(:accrue, cfs_directory)
    end

    it 'can manage CfsFile-related actions if they manage the file' do
      expect(ability).to be_able_to(:create_file_format_test, cfs_file)
      expect(ability).to be_able_to(:update_file_format_test, cfs_file)
      expect(ability).to be_able_to(:create_file_format_test_reason, cfs_file)
    end
  end
end
