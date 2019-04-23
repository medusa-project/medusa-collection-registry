class StaticPageMailer < MedusaBaseMailer

  def deposit_files_confirmation(deposit_files)
    @deposit_files = deposit_files
    mail(to: deposit_files.email)
  end

  def deposit_files_internal(deposit_files)
    @deposit_files = deposit_files
    mail(to: self.feedback_address, subject: default_i18n_subject(date_arg))
  end

  def feedback_confirmation(feedback)
    @feedback = feedback
    mail(to: feedback.email)
  end

  def feedback_internal(feedback)
    @feedback = feedback
    mail(to: feedback_address, subject: default_i18n_subject(date_arg))
  end

  def request_training_confirmation(request_training)
    @request_training = request_training
    mail(to: request_training.email)
  end

  def request_training_internal(request_training)
    @request_training = request_training
    mail(to: feedback_address, subject: default_i18n_subject(date_arg))
  end

  protected

  def date_arg
    {date: Date.today}
  end

end