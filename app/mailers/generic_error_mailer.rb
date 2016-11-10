class GenericErrorMailer < MedusaBaseMailer

  def error(message, subject: 'Generic Medusa Error')
    @message = message
    @process = $$
    @time = Time.now
    mail(to: self.class.dev_address, subject: subject)
  end

end