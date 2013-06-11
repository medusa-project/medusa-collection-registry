class TestMailer < ActionMailer::Base
  default :from => "noreply@#{self.smtp_settings['domain'].if_blank('illinois.edu')}"

  def test(address)
    mail(:to => address, :subject => 'test email subject')
  end

end