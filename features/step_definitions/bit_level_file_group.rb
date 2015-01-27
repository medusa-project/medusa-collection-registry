Given(/^The bit level file group statistics cache is up to date$/) do
  BitLevelFileGroup.update_cached_file_stats
end

Then(/^the file group titled '(.*)' should have an assessment scheduled$/) do |title|
  expect(Job::CfsInitialFileGroupAssessment.where(file_group_id: BitLevelFileGroup.where(title: title).first.try(:id))).to be_truthy
end

When(/^the file group titled '(.*)' has an assessment scheduled$/) do |title|
  Job::CfsInitialFileGroupAssessment.create(file_group_id: BitLevelFileGroup.where(title: title).first.try(:id))
end
