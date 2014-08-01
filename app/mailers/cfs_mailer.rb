class CfsMailer < ActionMailer::Base
  default from: "medusa-noreply@#{self.smtp_settings['domain'].if_blank('library.illinois.edu')}"

  def export_complete(job)
    @job = job
    mail(to: job.user.email, subject: 'Medusa export completed')
  end

end