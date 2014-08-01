And /^the file group named '(.*)' has an event with key '(.*)' performed by '(.*)'$/ do |name, key, email|
  file_group = FileGroup.find_by_name(name) || FactoryGirl.create(:file_group, :name => name)
  file_group.events.create(:key => key, :actor_email => email, :date => Date.today)
end

Then /^the file group named '(.*)' should have an event with key '(.*)' performed by '(.*)'$/ do |name, key, email|
  file_group = FileGroup.find_by_name(name)
  file_group.events.where(:key => key, :actor_email => email).first.should be_true
end

And(/^the file group named '(.*)' has events with fields:$/) do |name, table|
  file_group = FileGroup.find_by_name(name)
  table.hashes.each do |hash|
    FactoryGirl.create(:event, hash.merge(:eventable => file_group))
  end
end

Then(/^the file group named '(.*)' should have an event with fields:$/) do |name, table|
  file_group = FileGroup.find_by_name(name)
  table.hashes.each do |hash|
    file_group.events.where(hash).first.should be_true
  end
end

Then /^I should be on the events page for the file group named '(.*)'$/ do |name|
  current_path.should == events_file_group_path(FileGroup.find_by(name: name))
end

And(/^I should be viewing events for the collection titled '(.*)'$/) do |title|
  current_path.should == events_collection_path(Collection.find_by(title: title))
end

And /^I should see the events table$/ do
  page.should have_selector('table#events')
end

Then /^a (.*) is unauthorized to create an event for the file group named '(.*)'$/ do |user_type, name|
  if user_type == 'visitor'
      rack_login('a visitor')
      expected_path = unauthorized_path
    else
      expected_path = login_path
  end
  post events_path(:eventable_type => 'FileGroup', :eventable_id => FileGroup.find_by(:name => name))
  assert last_response.redirect?
  assert last_response.location.match(/#{expected_path}$/)
end
