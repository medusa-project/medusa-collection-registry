require 'rails_helper'

RSpec.describe 'OmniAuth::Shibboleth Configuration' do
  # set up mock shibboleth_config data
  let(:shibboleth_config) do
    {
      host: 'medusatest.library.illinois.edu',
      uid_field: 'eppn',
      extra_fields: %w[eppn givenName mail org_dn sn telephoneNumber uid entitlement unscoped_affiliation],
      request_type: 'header',
      info_fields: { email: 'mail' }
    }
  end

  before do
    # Mock Settings.shibboleth call and create the mocked object
    allow(Settings).to receive(:shibboleth).and_return(OpenStruct.new(shibboleth_config))
    @strategy = OmniAuth::Strategies::Shibboleth.new(nil, shibboleth_config.symbolize_keys)
  end

  it 'configures the Shibboleth provider with the correct settings' do
    expect(@strategy.options[:host]).to eq('medusatest.library.illinois.edu')
    expect(@strategy.options[:uid_field]).to eq('eppn')
    expect(@strategy.options[:extra_fields]).to eq(%w[eppn givenName mail org_dn sn telephoneNumber uid entitlement unscoped_affiliation])
    expect(@strategy.options[:request_type]).to eq('header')
    expect(@strategy.options[:info_fields]).to eq('email' => 'mail')
  end
end
