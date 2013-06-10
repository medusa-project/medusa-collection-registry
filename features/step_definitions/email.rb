And(/^'(.*)' should receive an email with subject '(.*)'$/) do |address, subject|
  open_email(address)
  current_email.subject.should == subject
end