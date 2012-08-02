#for shibboleth we need a config/shibboleth.yml file with the options
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    opts = YAML.load_file(File.join(Rails.root, 'config', 'shibboleth.yml'))
    provider :shibboleth, opts[Rails.env].symbolize_keys
  else
    provider :developer
  end
end