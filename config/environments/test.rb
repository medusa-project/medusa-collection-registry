MedusaCollectionRegistry::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Load environment-specific settings for the test environment
  # Note: The test.local.yml file is dynamically created during the Docker image build process.
  # It is generated by copying the contents of test.local-ci.yml into test.local.yml

  settings = YAML.unsafe_load(File.open(Rails.root.join('config', 'settings.yml')))
  local_settings = YAML.unsafe_load(File.open(Rails.root.join('config', 'settings', 'test.local.yml')))
  settings.merge!(local_settings)

  # configure mailer
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  config.action_mailer.smtp_settings = {
    address: settings["smtp"]["smtp_settings"]["address"],
    port: settings["smtp"]["smtp_settings"]["port"],
    authentication: :login,
    enable_starttls_auto: settings["smtp"]["smtp_settings"]["enable_starttls_auto"],
    user_name:settings["smtp"]["smtp_settings"]["user_name"],
    password: settings["smtp"]["smtp_settings"]["password"],
    domain: settings["smtp"]["smtp_settings"]["domain"]
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

  #disable asset compilation during tests
  # config.assets.compile = false
  # config.assets.debug = false
  # config.assets.quiet = true
end
