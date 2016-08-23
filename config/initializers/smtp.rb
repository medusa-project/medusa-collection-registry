require_relative 'config'
if Settings.smtp.present?
  unless Rails.env.test?
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = Settings.smtp.smtp_settings.to_h.with_indifferent_access
  end
  ActionMailer::Base.default_url_options = {host: Settings.smtp.web_host}
end
