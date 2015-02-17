class StaticPageMailer < MedusaBaseMailer

  def deposit_files_confirmation(deposit_files)
    @deposit_files = deposit_files
    mail(to: deposit_files.email, subject: "Medusa ingest request confirmation")
  end

  def deposit_files_internal(deposit_files)
    @deposit_files = deposit_files
    mail(to: self.feedback_address, subject: "Medusa ingest request [#{Date.today}]")
  end

  def feedback_confirmation(feedback)
    @feedback = feedback
    mail(to: feedback.email, subject: "Medusa feedback confirmation")
  end

  def feedback_internal(feedback)
    @feedback = feedback
    mail(to: feedback_address, subject: "Medusa feedback [#{Date.today}]")
  end

  def request_training_confirmation(request_training)
    @request_training = request_training
    mail(to: request_training.email, subject: "Medusa training request confirmation")
  end

  def request_training_internal(request_training)
    @request_training = request_training
    mail(to: feedback_address, subject: "Medusa training request [#{Date.today}]")
  end

end