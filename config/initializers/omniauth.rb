Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :shibboleth, :host => 'medusatest.library.illinois.edu'
  else
    provider :developer
  end
end