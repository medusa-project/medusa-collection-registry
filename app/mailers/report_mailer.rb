class ReportMailer < MedusaBaseMailer

  def cfs_directory_map(job, report_io)
    @job = job
    attachments['report.txt'] = report_io.string
    mail(to: job.user.email)
  end

  def cfs_directory_manifest(job, report_io)
    @job = job
    attachments['report.tsv'] = report_io.string
    mail(to: job.user.email)
  end

end