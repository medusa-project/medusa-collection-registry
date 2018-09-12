class DelayedJobErrorMailer < MedusaBaseMailer

  def error(job, exception)
    @job = job
    @exception = exception.to_s
    mail(to: dev_address)
  end
end