class Workflow::FileGroupDeleteMailer < MedusaBaseMailer

  def requester_accept(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: 'Medusa File Group deletion approved'
  end

  def requester_reject(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: 'Medusa File Group deletion rejected'
  end


  def email_superusers(workflow)
    @workflow = workflow
    mail to: Settings.superusers, subject: 'Medusa File Group deletion requested'
  end

  def requester_final_removal(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: 'Medusa File Group final deletion completed'
  end
end
