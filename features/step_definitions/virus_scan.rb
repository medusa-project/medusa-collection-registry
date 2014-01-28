Then(/^the file group named '(.*)' should have (\d+) virus scans? attached$/) do |name, count|
  FileGroup.find_by_name(name).virus_scans.count.to_s.should == count
end

When(/^I view the most recent virus scan$/) do
  visit virus_scan_path(VirusScan.order('created_at desc').first)
end