class Workflow::ProjectItemIngestMailer < MedusaBaseMailer

  def started(workflow)
    @workflow = workflow
    mail to: workflow.user.email, subject: 'Project Item ingest started'
  end

  def done(workflow)
    @workflow = workflow
    mail to: workflow.user.email, subject: 'Project Item ingest completed'
  end
end
