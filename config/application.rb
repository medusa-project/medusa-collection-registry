require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module MedusaCollectionRegistry
  class Application < Rails::Application
    attr_accessor :shibboleth_host
    attr_accessor :medusa_host
    attr_accessor :bit_file_tmp_dir
    attr_accessor :group_resolver
    attr_accessor :glacier_logger
    attr_accessor :storage_manager

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # configure mailer
    config.action_mailer.perform_caching = false
    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
      address: "smtp.sparkpostmail.com",
      port: 587,
      enable_starttls_auto: true,
      user_name: "SMTP_Injection",
      password: Settings.smtp.smtp_settings.password,
      domain: 'library.illinois.edu'
    }

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.unknown_asset_fallback = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.4'

    config.react.addons = true

    #https://guides.rubyonrails.org/active_record_multiple_databases.html#migrate-to-the-new-connection-handling
    config.active_record.legacy_connection_handling = false

    config.active_job.queue_adapter = :delayed_job

  end
end

#establish a short cut for the Application object
Application = MedusaCollectionRegistry::Application