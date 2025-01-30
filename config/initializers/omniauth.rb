Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production? || Rails.env.demo?
    # Shibboleth provider for production and demo environments
    opts = Settings.shibboleth
    provider :shibboleth, opts.to_h.symbolize_keys
    MedusaCollectionRegistry::Application.shibboleth_host = opts.host
  else
    # Developer strategy for development and test environments
    provider :developer,
             fields: [:email, :name],
             uid_field: :email
  end
end

OmniAuth.config.logger = Rails.logger
OmniAuth.config.request_validation_phase = nil if Rails.env.development? || Rails.env.test?

