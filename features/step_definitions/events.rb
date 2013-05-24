And /^the file group named '(.*)' has an event with key '(.*)' performed by '(.*)'$/ do |name, key, uid|
  file_group = FileGroup.find_by_name(name) || FactoryGirl.create(:file_group, :name => name)
  file_group.events.create(:key => key, :actor_netid => uid, :date => Date.today)
end

Then /^the file group named '(.*)' should have an event with key '(.*)' performed by '(.*)'$/ do |name, key, uid|
  file_group = FileGroup.find_by_name(name)
  file_group.events.where(:key => key, :actor_netid => uid).first.should be_true
end

Then(/^the file group named '(.*)' should have an event with fields:$/) do |name, table|
  file_group = FileGroup.find_by_name(name)
  table.hashes.each do |hash|
    file_group.events.where(hash).first.should be_true
  end
end

Then /^I should be on the events page for the file group named '(.*)'$/ do |name|
  current_path.should == events_file_group_path(FileGroup.find_by_name(name))
end

And /^I should see the events table$/ do
  page.should have_selector('table#events')
end

