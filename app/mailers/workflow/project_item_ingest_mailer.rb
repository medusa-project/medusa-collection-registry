class Workflow::ProjectItemIngestMailer < MedusaBaseMailer

  def started(workflow)
    @workflow = workflow
    mail(to: workflow.user.email)
  end

  def progress(workflow)
    @workflow = workflow
    mail(to: workflow.user.email)
  end

  def done(workflow)
    @workflow = workflow
    mail(to: workflow.user.email)
  end

  def staging_directory_missing(workflow)
    @workflow = workflow
    mail(to: workflow.user.email)
  end

  def target_directory_missing(workflow)
    @workflow = workflow
    mail(to: workflow.user.email)
  end
end
