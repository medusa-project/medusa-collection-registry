Given(/^I am running a virus scan job for the file group titled '([^']*)'$/) do |title|
  file_group = FileGroup.find_by(title: title)
  FactoryBot.create(:virus_scan_job, file_group_id: file_group.id)
end