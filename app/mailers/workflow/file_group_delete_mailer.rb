class Workflow::FileGroupDeleteMailer < MedusaBaseMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.workflow.file_group_delete_mailer.requester_accept.subject
  #
  def requester_accept(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: 'Medusa File Group deletion approved'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.workflow.file_group_delete_mailer.requester_reject.subject
  #
  def requester_reject(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: 'Medusa File Group deletion rejected'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.workflow.file_group_delete_mailer.admins_start.subject
  #
  def admins_start
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.workflow.file_group_delete_mailer.requester_final_removal.subject
  #
  def requester_final_removal(workflow)
    @workflow = workflow
    mail to: workflow.requester.email, subject: 'Medusa File Group final deletion completed'
  end
end
