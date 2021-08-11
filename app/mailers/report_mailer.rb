class ReportMailer < MedusaBaseMailer

  def cfs_directory_map(job, report_path)
    @job = job
    attachments['report.txt'] = File.read(report_path)
    mail(to: job.user.email)
  end

  def cfs_directory_manifest(job, report_path)
    @job = job
    attachments['report.tsv'] = File.read(report_path)
    mail(to: job.user.email)
  end

end