class Workflow::ProjectItemIngestMailer < MedusaBaseMailer

  def started(workflow)
    @workflow = workflow
    mail to: workflow.user.email, subject: subject('Project Item ingest started')
  end

  def progress(workflow)
    @workflow = workflow
    mail to: workflow.user.email, subject: subject('Project Item ingest progress')
  end

  def done(workflow)
    @workflow = workflow
    mail to: workflow.user.email, subject: subject('Project Item ingest completed')
  end

  def staging_directory_missing(workflow)
    @workflow = workflow
    mail to: workflow.user.email, subject: subject('Project Item ingest error')
  end

  def target_directory_missing(workflow)
    @workflow = workflow
    mail to: workflow.user.email, subject: subject('Project Item ingest error')
  end
end
