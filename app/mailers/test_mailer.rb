class TestMailer < ActionMailer::Base
  def test(address)
    mail(:to => address, :from => 'noreply@medusa-test.library.illinois.edu', :subject => 'test email subject')
  end
end