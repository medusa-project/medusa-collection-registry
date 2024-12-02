MedusaCollectionRegistry::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Load main settings file
  settings = YAML.unsafe_load(File.read(Rails.root.join('config', 'settings.yml')))

  # Load environment-specific settings if they exist
  if File.exist?(Rails.root.join('config', 'settings', 'development.local.yml'))
    local_settings = YAML.unsafe_load(File.read(Rails.root.join('config', 'settings', 'development.local.yml')))
    settings.merge!(local_settings)
  end

  # Load Docker-specific settings if they exist
  if File.exist?(Rails.root.join('config', 'settings', 'development-docker.local.yml'))
    docker_settings = YAML.unsafe_load(File.read(Rails.root.join('config', 'settings', 'development-docker.local.yml')))
    settings.merge!(docker_settings)
  end

  # Apply the merged settings to Config
  Config.load_and_set_settings(settings)

  # configure mailer
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: settings["smtp"]["smtp_settings"]["address"],
    port: settings["smtp"]["smtp_settings"]["port"],
    authentication: :login,
    enable_starttls_auto: settings["smtp"]["smtp_settings"]["enable_starttls_auto"],
    user_name:settings["smtp"]["smtp_settings"]["user_name"],
    password: settings["smtp"]["smtp_settings"]["password"],
    domain: settings["smtp"]["smtp_settings"]["domain"]
  }
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Allow BetterErrors to be accessed from any IP address. This is useful for debugging in Docker
  # Only enabled in development environment and not in production.
  BetterErrors::Middleware.allow_ip! "0.0.0.0/0" if defined?(BetterErrors)

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  #config.action_controller.perform_caching = true
  config.cache_store = :mem_cache_store, "memcached:11211"

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false
  #config.assets.compress = true

  # Expands the lines which load the assets
  #Use config.assets.debug = false to use newrelic, etc. where we don't want all those individual requests
  config.assets.debug = true
  #config.assets.debug = false
  config.assets.logger = false

  config.eager_load = false

  # (default is :info)
  config.log_level = :warn

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.after_initialize do
    if defined? Bullet
      Bullet.enable = true
      Bullet.alert = true
      Bullet.bullet_logger = true
      Bullet.console = true
      #Bullet.growl = true
      # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
      #                 :password => 'bullets_password_for_jabber',
      #                 :receiver => 'your_account@jabber.org',
      #                 :show_online_status => true }
      Bullet.rails_logger = true
      # Bullet.honeybadger = true
      # Bullet.bugsnag = true
      # Bullet.airbrake = true
      # Bullet.rollbar = true
      Bullet.add_footer = true
      # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
      # Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
      # Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
    end
  end
end

