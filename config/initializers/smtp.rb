config_hash = YAML.load_file(File.join(Rails.root, 'config', 'smtp.yml'))[Rails.env]
if config_hash
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.default_url_options = {:host => config_hash['web_host']}
  ActionMailer::Base.smtp_settings = config_hash['smtp_settings']
end
