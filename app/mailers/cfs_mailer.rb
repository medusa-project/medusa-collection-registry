class CfsMailer < MedusaBaseMailer

  def export_complete(text, email, response)
    @text = text
    @response = response
    mail(to: email, subject: 'Medusa Download ready')
  end

  def export_error_user(text, email, response)
    @text = text
    @response = response
    mail(to: email, subject: 'Medusa Download error')
  end

  def export_error_admin(text, response)
    @text = text
    @response = response
    mail(to: self.class.admin_address, subject: 'Medusa Download error')
  end

end