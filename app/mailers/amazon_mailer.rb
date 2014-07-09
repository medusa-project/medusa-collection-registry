class AmazonMailer < ActionMailer::Base
  default from: "medusa-noreply@#{self.smtp_settings['domain'].if_blank('library.illinois.edu')}"

  def progress(amazon_backup, part)
    @amazon_backup = amazon_backup
    @part = part.to_i
    mail(to: "#{amazon_backup.user.uid}@illinois.edu", subject: 'Amazon backup progress')
  end

  def failure(amazon_backup, error_message)
    @amazon_backup = amazon_backup
    @error_message = error_message
    mail(to: "#{amazon_backup.user.uid}@illinois.edu", subject: 'Amazon backup failure')
  end

end