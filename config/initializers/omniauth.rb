#for shibboleth we need a config/shibboleth.yml file with the options
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    opts = YAML.load_file(File.join(Rails.root, 'config', 'shibboleth.yml'))[Rails.env]
    provider :shibboleth, opts.symbolize_keys
    MedusaCollectionRegistry::Application.shibboleth_host = opts['host']
  else
    provider :developer
  end
end
OmniAuth.config.logger = Rails.logger