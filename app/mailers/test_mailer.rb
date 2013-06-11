class TestMailer < ActionMailer::Base
  def test(address)
    mail(:to => address, :from => 'noreply@medusatest.library.illinois.edu', :subject => 'test email subject')
  end
end