class Workflow::AccrualMailer < MedusaBaseMailer
  default from: "medusa-noreply@#{self.smtp_settings['domain'].if_blank('library.illinois.edu')}"

  def done(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: subject('Accrual completed'))
  end

  def initial_approval(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: subject('Accrual pending'))
  end

  def illegal_overwrite(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: subject('Accrual cancelled'))
  end

  def aborted(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: subject('Accrual aborted'))
  end

  def notify_admin_of_incoming_request(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: self.admin_address, subject: subject('Accrual requested'))
  end

  def assessment_done(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: [@workflow_accrual.user.email, @workflow_accrual.collection&.contact&.email].compact.uniq,
         subject: subject('Accrual assessment completed'))
  end

end