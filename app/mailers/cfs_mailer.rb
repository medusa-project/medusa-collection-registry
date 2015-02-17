class CfsMailer < MedusaBaseMailer

  def export_complete(job)
    @job = job
    mail(to: job.user.email, subject: 'Medusa export completed')
  end

end