class TestMailer < MedusaBaseMailer

  def test(address)
    mail(to: address)
  end

end