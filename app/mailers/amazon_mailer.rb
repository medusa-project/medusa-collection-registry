class AmazonMailer < MedusaBaseMailer

  def progress(amazon_backup)
    @amazon_backup = amazon_backup
    @workflow_ingest = @amazon_backup.workflow_ingest
    mail(to: amazon_backup.user.email, subject: 'Amazon backup progress')
  end

  def failure(amazon_backup, error_message)
    @amazon_backup = amazon_backup
    @error_message = error_message
    mail(to: amazon_backup.user.email, subject: 'Amazon backup failure')
  end

end