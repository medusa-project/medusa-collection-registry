And(/^'(.*)' should receive an email with subject '(.*)'$/) do |address, subject|
  open_email(address)
  expect(current_emails.detect {|email| email.subject == subject}).to be_truthy
end