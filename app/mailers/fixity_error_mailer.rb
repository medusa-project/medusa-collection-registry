class FixityErrorMailer < MedusaBaseMailer

  def report_problems
    mail(to: self.class.admin_address, subject: 'Medusa Fixity Errors')
  end

end