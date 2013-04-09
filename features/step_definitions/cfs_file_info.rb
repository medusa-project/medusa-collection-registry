And(/^I remove cfs orphan files under '(.*)'$/) do |path|
  CfsFileInfo.remove_orphans(path)
end

Then(/^there should not be cfs file info for '(.*)'$/) do |path|
  CfsFileInfo.find_by_path(path).should be_nil
end

Given(/^the cfs file info for the path '(.*)' has fields:$/) do |path, table|
  file_info = CfsFileInfo.find_or_create_by_path(path)
  table.hashes.each do |h|
    file_info.update_attributes!(h)
  end
end

And(/^the cfs file '(.*)' should have (\d+) red flags?$/) do |path, count|
  file_info = CfsFileInfo.find_by_path(path)
  file_info.red_flags.count.to_s.should == count
end