config_hash = YAML.load_file(File.join(Rails.root, 'config', 'smtp.yml'))[Rails.env]
if config_hash
  MedusaRails3::Application.config do |config|
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = config_hash['smtp_settings']
    config.action_mailer.default_url_options = {:host => config_hash['web_host']}
  end
end
