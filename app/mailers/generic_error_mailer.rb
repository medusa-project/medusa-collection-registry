class GenericErrorMailer < MedusaBaseMailer

  def error(message)
    @message = message
    mail(to: self.class.dev_address, subject: 'Generic Medusa Error')
  end

end