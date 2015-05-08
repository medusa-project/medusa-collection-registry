class Workflow::AccrualMailer < ActionMailer::Base

  def done(workflow_accrual)
    @workflow_accrual = workflow_accrual
    mail(to: @workflow_accrual.user.email, subject: 'Medusa accrual completed')
  end

end