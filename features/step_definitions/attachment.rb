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

def setup_assessment_creation_and_return_expected_path(user_type)
  if user_type == 'visitor'
      rack_login('a visitor')
      unauthorized_path
    else
      login_path
    end
end
