class CfsMailer < MedusaBaseMailer

  def export_complete(request, response)
    @request = request
    @response = response
    mail(to: request.email, subject: 'Medusa Download ready')
  end

  def export_error_user(request, response)
    @request = request
    @response = response
    mail(to: request.email, subject: 'Medusa Download error')
  end

  def export_error_admin(request, response)
    @request = request
    @response = response
    mail(to: self.class.admin_address, subject: 'Medusa Download error')
  end

end