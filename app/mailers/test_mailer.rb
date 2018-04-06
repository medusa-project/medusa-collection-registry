class TestMailer < MedusaBaseMailer

  def test(address)
    mail(to: address, subject: subject('Test email subject'))
  end

end