MedusaCollectionRegistry::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  settings = YAML.load("/config/settings.yml").symbolize_keys
  local_settings = YAML.load("/config/settings/test.local.yml").symbolize_keys
  settings.merge!(local_settings)

  # configure mailer
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: "smtp.sparkpostmail.com",
    port: 587,
    enable_starttls_auto: true,
    user_name: "SMTP_Injection",
    password: settings.smtp.smtp_settings.password,
    domain: 'library.illinois.edu'
  }

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.public_file_server.enabled = true
  config.public_file_server.headers = {'Cache-Control' => 'public, max-age=3600'}

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  #config.eager_load = true
  config.eager_load = false
  config.cache_store = :mem_cache_store

  config.colorize_logging = false

  config.middleware.use RackSessionAccess::Middleware

  #config.assets.compile = false

end
