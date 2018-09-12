class StaticPageMailer < MedusaBaseMailer

  before_action :add_date_arg, only: %i(deposit_files_internal feedback_internal, request_training_internal)

  def deposit_files_confirmation(deposit_files)
    @deposit_files = deposit_files
    mail(to: deposit_files.email)
  end

  def deposit_files_internal(deposit_files)
    @deposit_files = deposit_files
    mail(to: self.feedback_address)
  end

  def feedback_confirmation(feedback)
    @feedback = feedback
    mail(to: feedback.email)
  end

  def feedback_internal(feedback)
    @feedback = feedback
    mail(to: feedback_address)
  end

  def request_training_confirmation(request_training)
    @request_training = request_training
    mail(to: request_training.email)
  end

  def request_training_internal(request_training)
    @request_training = request_training
    mail(to: feedback_address)
  end

  protected

  def add_date_arg
    @subject_args = {date: Date.today}
  end

end