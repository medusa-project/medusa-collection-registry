require_relative 'config'
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    opts = Settings.shibboleth
    provider :shibboleth, opts.to_h.symbolize_keys
    MedusaCollectionRegistry::Application.shibboleth_host = opts.host
  else
    provider :identity, on_failed_registration: lambda { |env|
      IdentitiesController.action(:new).call(env)
    }
  end
end
OmniAuth.config.logger = Rails.logger
