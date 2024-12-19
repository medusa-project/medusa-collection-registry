require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    context 'when in production environment' do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it 'saves the referring page in the session' do
        request.env['HTTP_REFERER'] = '/login/page'
        get :new
        expect(session[:login_return_referer]).to eq('/login/page')
      end

      it 'redirects to the Shibboleth login path' do
        mocked_url = 'mock-shibboleth.local'
        allow(MedusaCollectionRegistry::Application).to receive(:shibboleth_host).and_return(mocked_url)
        get :new
        expected_redirect_url = "/Shibboleth.sso/Login?target=https://#{mocked_url}/auth/shibboleth/callback"
        expect(response).to redirect_to(expected_redirect_url)
      end
    end

    context 'when in non-production environment' do
      before { allow(Rails.env).to receive(:production?).and_return(false) }

      it 'redirects to /auth/identity' do
        get :new
        expect(response).to redirect_to('/auth/identity')
      end
    end
  end

  describe 'POST #create' do
    context 'when using Shibboleth in production' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        OmniAuth.config.test_mode = true
        session[:login_return_uri] = '/dashboard'
      end

      after do
        OmniAuth.config.test_mode = false
        OmniAuth.config.mock_auth[:shibboleth] = nil
      end

      it 'authenticates the user and sets the session' do
        OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new(
          provider: 'shibboleth',
          uid: 'testuser@illinois.edu',
          info: { email: 'testuser@illinois.edu' }
        )
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:shibboleth]
        post :create, params: { provider: 'shibboleth' }
        user = User.find_by(uid: 'testuser@illinois.edu')
        expect(user).to be_present
        expect(session[:current_user_id]).to eq(user.id)
        expect(response).to redirect_to('/dashboard')
      end

      it 'redirects to login if Shibboleth attributes are missing' do
        OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new(
          provider: 'shibboleth',
          uid: nil,
          info: { email: nil }
        )
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:shibboleth]
        post :create, params: { provider: 'shibboleth' }
        expect(session[:current_user_id]).to be_nil
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when using Identity in development' do
      before { allow(Rails.env).to receive(:production?).and_return(false) }

      it 'authenticates the user in development mode' do
        post :create, params: { provider: 'identity', auth_key: 'testuser@illinois.edu' }
        user = User.find_by(uid: 'testuser@illinois.edu')
        expect(user).to be_present
        expect(session[:current_user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to login if auth_key is missing' do
        request.params['auth_key'] = nil
        post :create, params: { provider: 'identity' }
        expect(session[:user_id]).to be_nil
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when using Developer strategy in development' do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
          provider: 'developer',
          uid: 'testuser@illinois.edu',
          info: { email: 'testuser@illinois.edu', name: 'Test User' }
        )
      end

      after { OmniAuth.config.test_mode = false }

      it 'authenticates the user with developer strategy' do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:developer]
        post :create, params: { provider: 'developer' }
        user = User.find_by(email: 'testuser@illinois.edu')
        expect(user).to be_present
        expect(session[:current_user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
