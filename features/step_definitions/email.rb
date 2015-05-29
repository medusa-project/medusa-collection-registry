And(/^'([^']*)' should receive an email with subject '([^']*)'$/) do |address, subject|
  open_email(address)
  expect(current_emails.detect {|email| email.subject == subject}).to be_truthy
end

And(/^'([^']*)' should receive an email with subject '([^']*)' containing all of:$/) do |address, subject, table|
  open_email(address)
  possible_emails = current_emails.select {|email| email.subject == subject}
  table.headers.each do |header|
    possible_emails = possible_emails.select {|email| email.body.match(header)}
    expect(possible_emails).to be_present
  end
end

And(/^the feedback address should receive an email with subject \/(.*)\/ matching all of:$/) do |subject_regexp, table|
  open_email(MedusaBaseMailer.feedback_address)
  expect(current_emails.size).to eq(1)
  email = current_emails.first
  expect(email.subject).to match(subject_regexp)
  table.headers.each do |header|
    expect(email.body).to match(header)
  end
end