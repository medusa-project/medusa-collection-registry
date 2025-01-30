require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'User creation' do
    let(:user_attributes) do
      {
        uid: 'testuser@illinois.edu',
        email: 'testuser@illinois.edu'
      }
    end

    context 'when creating a new user' do
      it 'creates a user with the correct attributes' do
        user = User.create!(
          uid: user_attributes[:uid],
          email: user_attributes[:email]
        )

        expect(user).to be_persisted
        expect(user.uid).to eq('testuser@illinois.edu')
        expect(user.email).to eq('testuser@illinois.edu')
      end
    end

    context 'when a user already exists with the same uid' do
      it 'does not create a duplicate user' do
        existing_user = User.create!(
          uid: user_attributes[:uid],
          email: user_attributes[:email]
        )

        expect {
          User.create!(
            uid: user_attributes[:uid],
            email: user_attributes[:email]
          )
        }.to raise_error(ActiveRecord::RecordInvalid, /Uid has already been taken/)

        expect(User.count).to eq(1)
        expect(User.first).to eq(existing_user)
      end
    end

    context 'when a user already exists with the same email' do
      it 'does not create a duplicate user' do
        existing_user = User.create!(
          uid: 'differentuid@illinois.edu',
          email: user_attributes[:email]
        )

        expect {
          User.create!(
            uid: user_attributes[:uid],
            email: user_attributes[:email]
          )
        }.to raise_error(ActiveRecord::RecordInvalid, /Email has already been taken/)

        expect(User.count).to eq(1)
        expect(User.first).to eq(existing_user)
      end
    end
  end

  describe 'Roles and Permissions' do
    context 'when user is a superuser' do
      let(:user) { FactoryBot.create(:user, email: 'superuser@illinois.edu', uid: 'superuser@illinois.edu') }

      it 'returns true for #superuser?' do
        allow(GroupManager.instance.resolver).to receive(:is_ad_superuser?).with(user).and_return(true)
        expect(user.superuser?).to be true
      end
    end

    context 'when user is a project admin' do
      let(:user) { FactoryBot.create(:user, email: 'projectadmin@illinois.edu', uid: 'projectadmin@illinois.edu') }

      it 'returns true for #project_admin?' do
        allow(GroupManager.instance.resolver).to receive(:is_ad_project_admin?).with(user).and_return(true)
        expect(user.project_admin?).to be true
      end
    end

    context 'when user is a medusa admin' do
      let(:user) { FactoryBot.create(:user, email: 'medusaadmin@illinois.edu', uid: 'medusaadmin@illinois.edu') }

      it 'returns true for #medusa_admin?' do
        allow(GroupManager.instance.resolver).to receive(:is_ad_admin?).with(user).and_return(true)
        expect(user.medusa_admin?).to be true
      end
    end
  end
end
