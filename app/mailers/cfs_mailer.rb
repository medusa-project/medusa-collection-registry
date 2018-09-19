class CfsMailer < MedusaBaseMailer

  def export_complete(text, email, response)
    @text = text
    @response = response
    mail(to: email)
  end

  def export_error_user(text, email, response)
    @text = text
    @response = response
    mail(to: email)
  end

  def export_error_admin(text, response)
    @text = text
    @response = response
    mail(to: self.class.admin_address)
  end

end