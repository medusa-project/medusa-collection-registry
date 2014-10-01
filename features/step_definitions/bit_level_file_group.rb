Given(/^The bit level file group statistics cache is up to date$/) do
  BitLevelFileGroup.update_cached_file_stats
end

Then(/^the file group named '(.*)' should have an assessment scheduled$/) do |name|
  expect(Job::CfsInitialFileGroupAssessment.where(file_group_id: BitLevelFileGroup.where(name: name).first.try(:id))).to be_truthy
end

When(/^the file group named '(.*)' has an assessment scheduled$/) do |name|
  Job::CfsInitialFileGroupAssessment.create(file_group_id: BitLevelFileGroup.where(name: name).first.try(:id))
end
