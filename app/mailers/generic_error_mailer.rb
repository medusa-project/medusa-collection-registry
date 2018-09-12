class GenericErrorMailer < MedusaBaseMailer

  def error(message, subject: 'Generic Medusa Error')
    @message = message
    @process = $$
    @time = Time.now
    @subject = subject
    mail(to: self.class.dev_address)
  end

end