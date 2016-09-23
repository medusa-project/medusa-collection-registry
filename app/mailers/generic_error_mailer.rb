class GenericErrorMailer < MedusaBaseMailer

  def error(message)
    @message = message
    @process = $$
    @time = Time.now
    mail(to: self.class.dev_address, subject: 'Generic Medusa Error')
  end

end