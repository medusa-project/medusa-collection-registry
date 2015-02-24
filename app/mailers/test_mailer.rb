class TestMailer < MedusaBaseMailer

  def test(address)
    mail(to: address, subject: 'test email subject')
  end

end