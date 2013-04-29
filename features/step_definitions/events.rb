And /^the file group named '(.*)' has an event with key '(.*)' performed by '(.*)'$/ do |name, key, uid|
  file_group = FileGroup.find_by_name(name) || FactoryGirl.create(:file_group, :name => name)
  user = User.find_by_uid(uid) || FactoryGirl.create(:user, :uid => uid)
  file_group.events.create(:key => key, :user_id => user.id)
end

Then /^the file group named '(.*)' should have an event with key '(.*)' performed by '(.*)'$/ do |name, key, uid|
  file_group = FileGroup.find_by_name(name)
  file_group.events.where(:key => key, :user_id => User.find_by_uid(uid).id).first.should be_true
end

Then /^I should be on the events page for the file group named '(.*)'$/ do |name|
  current_path.should == events_file_group_path(FileGroup.find_by_name(name))
end

And /^I should see the events table$/ do
  page.should have_selector('table#events')
end

Then(/^I should be creating an event for the file group named '(.*)'$/) do |name|
  pending # express the regexp above with the code you wish you had
end
