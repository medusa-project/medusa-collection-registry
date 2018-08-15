And(/^'([^']*)' should receive an email with subject '([^']*)'$/) do |address, subject|
  open_email(address)
  all = current_emails
  subs = current_emails.collect {|email| email.subject}
  expect(current_emails.detect {|email| email.subject == subject}).to be_truthy
end

And(/^'([^']*)' should receive an email with subject '([^']*)' containing all of:$/) do |address, subject, table|
  open_email(address)
  # x = current_emails
  # y = current_emails.collect(&:subject)
  # z = subject
  # t = all_emails
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

And(/^'(.*)' should receive an email with attachment '(.*)'$/) do |address, attachment_name|
  open_email(address)
  email = current_emails.detect do |email|
    email.attachments.detect do |attachment|
      attachment.filename == attachment_name
    end
  end
  expect(email).to be_truthy
end