class Workflow::FileGroupDeleteMailer < MedusaBaseMailer

  def requester_accept(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: subject('File Group deletion approved')
  end

  def requester_reject(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: subject('File Group deletion rejected')
  end

  def restored_content(workflow)
    @workflow = workflow
    mail to: requester_and_superusers(workflow), subject: subject('File Group deletion cancelled - content restored')
  end

  def email_superusers(workflow)
    @workflow = workflow
    mail to: Settings.superusers, subject: subject('File Group deletion requested')
  end

  def requester_final_removal(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: subject('File Group final deletion completed')
  end

  protected

  def requester_and_superusers(workflow)
    Settings.superusers << workflow.requester.email
  end
end
