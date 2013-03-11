And /^the file group named '(.*)' has an event with message '(.*)' performed by '(.*)'$/ do |name, message, uid|
  file_group = FileGroup.find_by_name(name) || FactoryGirl.create(:file_group, :name => name)
  user = User.find_by_uid(uid) || FactoryGirl.create(:user, :uid => uid)
  file_group.events.create(:message => message, :user_id => user.id)
end

Then /^I should be on the events page for the file group named '(.*)'$/ do |name|
  current_path.should == events_file_group_path(FileGroup.find_by_name(name))
end

And /^I should see the events table$/ do
  page.should have_selector('table#events')
end
