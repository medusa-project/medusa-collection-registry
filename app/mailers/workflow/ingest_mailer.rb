class Workflow::IngestMailer < MedusaBaseMailer
  default from: "medusa-noreply@library.illinois.edu"

  def done(workflow_ingest)
    @workflow_ingest = workflow_ingest
    @file_group = workflow_ingest.bit_level_file_group
    mail(to: @workflow_ingest.user.email)
  end

  def staging_delete_done(user, external_file_group)
    @file_group = external_file_group
    mail(to: user.email)
  end

end