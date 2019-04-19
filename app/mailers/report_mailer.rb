class ReportMailer < MedusaBaseMailer

  def cfs_directory_map(job, report_io)
    @job = job
    @subject = subject("Medusa cfs directory map")
    attachments['report.txt'] = report_io.string
    mail(to: job.user.email)
  end

  def cfs_directory_manifest(job, report_io)
    @job = job
    @subject = subject("Medusa cfs directory manifest")
    attachments['report.tsv'] = report_io.string
    mail(to: job.user.email)
  end

end