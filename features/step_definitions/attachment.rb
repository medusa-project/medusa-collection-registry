Then /^a (.*) is unauthorized to start an attachment for the collection titled '(.*)'$/ do |user_type, title|
  expected_path = setup_assessment_creation_and_return_expected_path(user_type)
  get new_attachment_path(:attachable_type => 'Collection',
                          :attachable_id => Collection.where(:title => title).first.id)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{expected_path}$/)
end

Then /^a (.*) is unauthorized to create an attachment for the collection titled '(.*)'$/ do |user_type, title|
  expected_path = setup_assessment_creation_and_return_expected_path(user_type)
  post attachments_path(:attachment => {:attachable_type => 'Collection',
                                        :attachable_id => Collection.where(:title => title).first.id})
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{expected_path}$/)
end

Then /^a (.*) is unauthorized to start an attachment for the file group named '(.*)'$/ do |user_type, name|
  expected_path = setup_assessment_creation_and_return_expected_path(user_type)
  get new_attachment_path(:attachable_type => 'FileGroup',
                          :attachable_id => FileGroup.where(:name => name).first.id)
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{expected_path}$/)
end

Then /^a (.*) is unauthorized to create an attachment for the file group named '(.*)'$/ do |user_type, name|
  expected_path = setup_assessment_creation_and_return_expected_path(user_type)
  post attachments_path(:attachment => {:attachable_type => 'FileGroup',
                                        :attachable_id => FileGroup.where(:name => name).first.id})
  expect(last_response.redirect?).to be_truthy
  expect(last_response.location).to match(/#{expected_path}$/)
end

Then(/^I should be on the download page for the attachment '(.*)'$/) do |file_name|
  current_path.should == download_attachment_path(Attachment.find_by_attachment_file_name(file_name))
end

And(/^the (.*) with (.*) '(.*)' should have (\d+) attachments?$/) do |object_type, key, value, count|
  klass = class_for_object_type(object_type)
  expect(klass.where(key.gsub(' ', '_') => value).first.attachments.count).to eq(count.to_i)
end

def setup_assessment_creation_and_return_expected_path(user_type)
  if user_type == 'visitor'
    rack_login('a visitor')
    unauthorized_path
  else
    login_path
  end
end
