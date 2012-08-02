Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :shibboleth
  else
    provider :developer
  end
end