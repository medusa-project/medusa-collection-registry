class MessageReceiverErrorMailer < MedusaBaseMailer

  def error
    mail(to: dev_address, subject: 'Medusa Message Receiver Error')
  end
end