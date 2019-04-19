class ReportMailer < MedusaBaseMailer

  def cfs_directory_map(job, report_io)
    @job = job
    attachments['report.txt'] = report_io.string
    mail(to: job.user.email, subject: subject("Medusa Report Map for #{job.cfs_directory.relative_path}"))
  end

  def cfs_directory_manifest(job, report_io)
    @job = job
    attachments['report.tsv'] = {content: report_io.string, mime_type: 'text/tab-separated-values'}
    mail(to: job.user.email, subject: subject("Medusa Report Manifest for #{job.cfs_directory.relative_path}"))
  end

end