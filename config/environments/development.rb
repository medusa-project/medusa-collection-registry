MedusaCollectionRegistry::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  settings = YAML.load("/config/settings.yml").symbolize_keys
  local_settings = YAML.load("/config/settings/development.local.yml").symbolize_keys
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

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

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

