Given(/^I am running a virus scan job for the file group named '(.*)'$/) do |name|
  file_group = FileGroup.find_by_name(name)
  FactoryGirl.create(:virus_scan_job, :file_group_id => file_group.id)
end