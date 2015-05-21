class Workflow::AccrualMailer < ActionMailer::Base
  default from: "medusa-noreply@#{self.smtp_settings['domain'].if_blank('library.illinois.edu')}"

  def done(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: 'Medusa accrual completed')
  end

  def duplicates(workflow_accrual, duplicate_set)
    @workflow_accrual = workflow_accrual
    @duplicate_set = duplicate_set
    mail(to: @workflow_accrual.user.email, subject: 'Medusa accrual aborted')
  end

  def initial_approval(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: 'Medusa accrual pending')
  end

  def aborted(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: 'Medusa accrual aborted')
  end

end