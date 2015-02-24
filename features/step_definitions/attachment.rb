Then /^a (.*) is unauthorized to start an attachment for the (.*) with (.*) '(.*)'$/ do |user_type, object_type, key, value|
  setup_and_check_assessment_creation_doing(user_type, object_type) do |klass|
    get new_attachment_path(attachable_type: klass.to_s, attachable_id: klass.find_by(key => value).id)
  end
end

Then /^a (.*) is unauthorized to create an attachment for the (.*) with (.*) '(.*)'$/ do |user_type, object_type, key, value|
  setup_and_check_assessment_creation_doing(user_type, object_type) do |klass|
    post attachments_path(attachment: {attachable_type: klass.to_s, attachable_id: klass.find_by(key => value).id})
  end
end

Then(/^I should be on the download page for the attachment '(.*)'$/) do |file_name|
  current_path.should == download_attachment_path(Attachment.find_by(attachment_file_name: file_name))
end

def setup_and_check_assessment_creation_doing(user_type, object_type)
  expected_path = if user_type == 'visitor'
                    rack_login('a visitor')
                    unauthorized_path
                  else
                    login_path
                  end
  yield class_for_object_type(object_type)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{expected_path}$/)
end
