And(/^I remove cfs orphan files under '(.*)'$/) do |path|
  CfsFileInfo.remove_orphans(path)
end

Then(/^there should not be cfs file info for '(.*)'$/) do |path|
  CfsFileInfo.find_by_path(path).should be_nil
end

Given(/^the cfs file info for the path '(.*)' has fields:$/) do |path, table|
  file_info = CfsFileInfo.find_or_create_by(path: path)
  table.hashes.each do |h|
    file_info.update_attributes!(h)
  end
end

And(/^there are cfs file infos with fields:$/) do |table|
  table.hashes.each do |h|
    file_info = CfsFileInfo.find_or_create_by(path: h[:path])
    file_info.update_attributes!(h)
  end
end

And(/^the cfs file '(.*)' should have (\d+) red flags?$/) do |path, count|
  file_info = CfsFileInfo.find_by_path(path)
  file_info.red_flags.count.to_s.should == count
end

#Given(/^the cfs file info for the path '(.*)' has red flags with fields:$/) do |path, table|
#  file_info = CfsFileInfo.find_or_create_by(path: path)
#  table.hashes.each do |h|
#    file_info.red_flags.create(h)
#  end
#end

#When(/^I view the first red flag for the cfs file info for the path '(.*)'$/) do |path|
#  file_info = CfsFileInfo.find_by_path(path)
#  visit red_flag_path(file_info.red_flags.first)
#end

#Then(/^I should be viewing the first red flag for the cfs file info for the path '(.*)'$/) do |path|
#  cfs_file_info = CfsFileInfo.find_by_path(path)
#  current_path.should == red_flag_path(cfs_file_info.red_flags.first)
#end

#Then(/^I should be editing the first red flag for the cfs file info for the path '(.*)'$/) do |path|
#  cfs_file_info = CfsFileInfo.find_by_path(path)
#  current_path.should == edit_red_flag_path(cfs_file_info.red_flags.first)
#end