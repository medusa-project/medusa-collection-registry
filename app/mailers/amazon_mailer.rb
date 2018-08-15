class AmazonMailer < MedusaBaseMailer

  def progress(amazon_backup)
    @amazon_backup = amazon_backup
    mail(to: amazon_backup.user.email, subject: subject('Amazon backup progress'))
  end

  def failure(amazon_backup, error_message)
    @amazon_backup = amazon_backup
    @error_message = error_message
    mail(to: [dev_address, amazon_backup.user.email], subject: subject('Amazon backup failure'))
  end

end