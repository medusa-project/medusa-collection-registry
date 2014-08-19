When(/^I view the most recent virus scan$/) do
  visit virus_scan_path(VirusScan.order('created_at desc').first)
end