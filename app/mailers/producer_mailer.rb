class ProducerMailer < MedusaBaseMailer

  def report(job, csv)
    @producer = job.producer
    attachments['report.csv'] = csv
    mail to: job.user.email, subject: subject('Producer Report')
  end

end
