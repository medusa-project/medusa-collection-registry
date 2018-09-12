class Workflow::FileGroupDeleteMailer < MedusaBaseMailer

  def requester_accept(workflow)
    @workflow = workflow
    mail(to: workflow.requester.email)
  end

  def requester_reject(workflow)
    @workflow = workflow
    mail(to: workflow.requester.email)
  end

  def restored_content(workflow)
    @workflow = workflow
    mail(to: requester_and_superusers(workflow))
  end

  def email_superusers(workflow)
    @workflow = workflow
    mail(to: Settings.superusers)
  end

  def requester_final_removal(workflow)
    @workflow = workflow
    mail(to: workflow.requester.email)
  end

  protected

  def requester_and_superusers(workflow)
    Settings.superusers << workflow.requester.email
  end
end
