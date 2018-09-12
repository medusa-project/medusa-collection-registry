class MessageReceiverErrorMailer < MedusaBaseMailer

  def error
    mail(to: dev_address)
  end
end