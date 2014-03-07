Then /^a (.*) is unauthorized to start an attachment for the collection titled '(.*)'$/ do |user_type, title|
  expected_path = setup_assessment_creation_and_return_expected_path(user_type)
  get new_attachment_path(:attachable_type => 'Collection',
                          :attachable_id => Collection.where(:title => title).first.id)
  assert last_response.redirect?
  assert last_response.location.match(/#{expected_path}$/)
end

Then /^a (.*) is unauthorized to create an attachment for the collection titled '(.*)'$/ do |user_type, title|
  expected_path = setup_assessment_creation_and_return_expected_path(user_type)
  post attachments_path(:attachment => {:attachable_type => 'Collection',
                                        :attachable_id => Collection.where(:title => title).first.id})
  assert last_response.redirect?
  assert last_response.location.match(/#{expected_path}$/)
end

And(/^the collection titled '(.*)' should have (\d+) attachments?$/) do |title, count|
  Collection.find_by_title(title).attachments.count.should == count.to_i
end

Then(/^I should be on the download page for the attachment '(.*)'$/) do |file_name|
  current_path.should == download_attachment_path(Attachment.find_by_attachment_file_name(file_name))
end

And(/^the file group named '(.*)' should have (\d+) attachment$/) do |name, count|
  expect(FileGroup.where(:name => name).first.attachments.count).to eq(count)
end

def setup_assessment_creation_and_return_expected_path(user_type)
  if user_type == 'visitor'
      rack_login('a visitor')
      unauthorized_path
    else
      login_path
    end
end
