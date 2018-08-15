class MessageReceiverErrorMailer < MedusaBaseMailer

  def error
    mail(to: dev_address, subject: subject('Message Receiver Error'))
  end
end