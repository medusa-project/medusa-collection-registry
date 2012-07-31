Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?

  else
    provider :developer
  end
end