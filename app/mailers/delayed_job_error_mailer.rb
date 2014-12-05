class DelayedJobErrorMailer < ActionMailer::Base
  default from: "medusa-noreply@#{self.smtp_settings['domain'].if_blank('library.illinois.edu')}"

  def error(job, exception)
    @handler = job.handler
    @exception = exception.to_s
    @id = job.id
    mail(to: 'hding2@illinois.edu', subject: 'Medusa Delayed Job Error')
  end
end