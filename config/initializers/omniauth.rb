Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production? || Rails.env.demo?
    # Shibboleth provider for production and demo environments
    opts = Settings.shibboleth
    provider :shibboleth, opts.to_h.symbolize_keys
    MedusaCollectionRegistry::Application.shibboleth_host = opts.host
  else
    # Developer strategy for development and test environments
    if Rails.env.development? || Rails.env.test?
      provider :developer,
               fields: [:email, :name, :role],
               uid_field: :email
    end

    # Identity provider for local environments
    provider :identity, on_failed_registration: lambda { |env|
      IdentitiesController.action(:new).call(env)
    }
  end
end
OmniAuth.config.logger = Rails.logger
