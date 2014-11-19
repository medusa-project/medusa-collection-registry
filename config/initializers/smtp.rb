config_hash = YAML.load_file(File.join(Rails.root, 'config', 'smtp.yml'))[Rails.env]
if config_hash
  unless Rails.env.test?
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = config_hash['smtp_settings']
  end
  ActionMailer::Base.default_url_options = {host: config_hash['web_host']}
end
