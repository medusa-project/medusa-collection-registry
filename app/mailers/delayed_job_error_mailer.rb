class DelayedJobErrorMailer < MedusaBaseMailer

  def error(job, exception)
    @job = job
    @exception = exception.to_s
    mail(to: dev_address, subject: 'Medusa Delayed Job Error')
  end
end