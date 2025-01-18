require 'rails_helper'

RSpec.describe GroupResolver::Test, type: :model do
  before do
    # Mock Settings.medusa values
    allow(Settings.medusa).to receive(:medusa_users_group).and_return('Library Medusa Users')
    allow(Settings.medusa).to receive(:medusa_admins_group).and_return('Library Medusa Admins')
    allow(Settings.medusa).to receive(:medusa_project_admins_group).and_return('Library Medusa Projects')
    allow(Settings.medusa).to receive(:medusa_superusers_group).and_return('Library Medusa Super Admins')
  end

  let(:resolver) { GroupResolver::Test.new }
  let(:user) { double('User', net_id: net_id) }

  describe '#is_member_of?' do
    context 'when the group is blank' do
      let(:net_id) { 'testuser@illinois.edu' }

      it 'returns false' do
        expect(resolver.is_member_of?(nil, user)).to be false
        expect(resolver.is_member_of?('', user)).to be false
      end
    end

    context 'when the net_id matches specific roles' do
      context 'when net_id matches superuser' do
        let(:net_id) { 'superadmin@illinois.edu' }

        it 'returns true for superuser and user groups' do
          expect(resolver.is_member_of?('Library Medusa Super Admins', user)).to be true
          expect(resolver.is_member_of?('Library Medusa Users', user)).to be true
        end
      end

      context 'when net_id matches admin' do
        let(:net_id) { 'adminuser@illinois.edu' }

        it 'returns true for admin and user groups' do
          expect(resolver.is_member_of?('Library Medusa Admins', user)).to be true
          expect(resolver.is_member_of?('Library Medusa Users', user)).to be true
        end
      end

      context 'when net_id matches project' do
        let(:net_id) { 'projectmanager@illinois.edu' }

        it 'returns true for project admin and user groups' do
          expect(resolver.is_member_of?('Library Medusa Projects', user)).to be true
          expect(resolver.is_member_of?('Library Medusa Users', user)).to be true
        end
      end

      context 'when net_id matches manager' do
        let(:net_id) { 'manageruser@illinois.edu' }

        it 'returns true for user and manager groups' do
          expect(resolver.is_member_of?('Library Medusa Users', user)).to be true
          expect(resolver.is_member_of?('manager', user)).to be true
        end
      end

      context 'when net_id matches user' do
        let(:net_id) { 'user@illinois.edu' }

        it 'returns true only for user group' do
          expect(resolver.is_member_of?('Library Medusa Users', user)).to be true
        end

        it 'returns false for other groups' do
          expect(resolver.is_member_of?('Library Medusa Admins', user)).to be false
        end
      end

      context 'when net_id matches outsider or visitor' do
        let(:net_id) { 'visitor@illinois.edu' }

        it 'returns false for all groups' do
          expect(resolver.is_member_of?('Library Medusa Users', user)).to be false
          expect(resolver.is_member_of?('Library Medusa Admins', user)).to be false
        end
      end
    end
  end
end
