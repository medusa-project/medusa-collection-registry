class CfsMailer < MedusaBaseMailer

  def export_complete(handler, response)
    @handler = handler
    @response = response
    mail(to: handler.email, subject: 'Medusa Download ready')
  end

  def export_error_user(handler, response)
    @handler = handler
    @response = response
    mail(to: handler.email, subject: 'Medusa Download error')
  end

  def export_error_admin(handler, response)
    @handler = handler
    @response = response
    mail(to: self.class.admin_address, subject: 'Medusa Download error')
  end

end