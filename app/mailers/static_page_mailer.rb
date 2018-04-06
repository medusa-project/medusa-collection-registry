class StaticPageMailer < MedusaBaseMailer

  def deposit_files_confirmation(deposit_files)
    @deposit_files = deposit_files
    mail(to: deposit_files.email, subject: subject('Ingest request confirmation'))
  end

  def deposit_files_internal(deposit_files)
    @deposit_files = deposit_files
    mail(to: self.feedback_address, subject: subject("Ingest request [#{Date.today}]"))
  end

  def feedback_confirmation(feedback)
    @feedback = feedback
    mail(to: feedback.email, subject: subject('Feedback confirmation'))
  end

  def feedback_internal(feedback)
    @feedback = feedback
    mail(to: feedback_address, subject: subject("Feedback [#{Date.today}]"))
  end

  def request_training_confirmation(request_training)
    @request_training = request_training
    mail(to: request_training.email, subject: subject('Training request confirmation'))
  end

  def request_training_internal(request_training)
    @request_training = request_training
    mail(to: feedback_address, subject: subject("Training request [#{Date.today}]"))
  end

end