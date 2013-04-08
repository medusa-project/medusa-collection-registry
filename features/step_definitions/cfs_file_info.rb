And(/^I remove cfs orphan files under '(.*)'$/) do |path|
  CfsFileInfo.remove_orphans(path)
end

Then(/^there should not be cfs file info for '(.*)'$/) do |path|
  CfsFileInfo.find_by_path(path).should be_nil
end