require 'fileutils'

And(/^the external file group with name '(.*)' is already being ingested$/) do |name|
  external_file_group = ExternalFileGroup.find_by(name: name)
  FactoryGirl.create(:workflow_ingest, external_file_group_id: external_file_group.id)
end

Given(/^an external file group with name '(.*)' is staged with bag data '(.*)'$/) do |name, bag_name|
  external_file_group = FactoryGirl.create(:external_file_group, name: name)
  staging_root = StagingStorage.instance.roots.to_a.sample
  local_staging_target = File.join(staging_root.local_path, external_file_group.collection.id.to_s)
  FileUtils.mkdir_p(local_staging_target)
  FileUtils.cp_r(File.join(Rails.root, 'features', 'fixtures', 'bags', bag_name, 'data'),
                 local_staging_target)
  FileUtils.mv(File.join(local_staging_target, 'data'), File.join(local_staging_target, external_file_group.id.to_s))
  external_file_group.staged_file_location = File.join(staging_root.remote_path, external_file_group.collection.id.to_s, external_file_group.id.to_s)
  external_file_group.save!
end

And(/^the external file group with name '(.*)' has a related bit level file group$/) do |name|
  external_file_group = ExternalFileGroup.find_by(name: name)
  bit_level_file_group = FactoryGirl.create(:bit_level_file_group)
  external_file_group.target_file_groups << bit_level_file_group
end

Then(/^the external file group with name '(.*)' should be in the process of ingestion$/) do |name|
  external_file_group = ExternalFileGroup.find_by(name: name)
  expect(external_file_group.workflow_ingest).to be_a(Workflow::Ingest)
end