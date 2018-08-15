class Workflow::IngestMailer < MedusaBaseMailer
  default from: "medusa-noreply@#{self.smtp_settings['domain'].if_blank('library.illinois.edu')}"

  def done(workflow_ingest)
    @workflow_ingest = workflow_ingest
    @file_group = workflow_ingest.bit_level_file_group
    mail(to: @workflow_ingest.user.email, subject: subject('Ingest completed'))
  end

  def staging_delete_done(user, external_file_group)
    @file_group = external_file_group
    mail(to: user.email, subject: subject('Staged content deleted'))
  end

end