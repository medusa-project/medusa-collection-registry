require 'fileutils'

And(/^the external file group with title '([^']*)' is already being ingested$/) do |title|
  external_file_group = ExternalFileGroup.find_by(title: title)
  FactoryBot.create(:workflow_ingest, external_file_group_id: external_file_group.id)
end

Given(/^an external file group with title '([^']*)' in collection '([^']*)' is staged with bag data '([^']*)'$/) do |file_group_title, collection_title, bag_name|
  collection = FactoryBot.create(:collection, title: collection_title)
  external_file_group = FactoryBot.create(:external_file_group, title: file_group_title, collection_id: collection.id)
  staging_root = StagingStorage.instance.roots.to_a.sample
  local_staging_target = File.join(staging_root.local_path, external_file_group.collection.id.to_s)
  FileUtils.mkdir_p(local_staging_target)
  FileUtils.cp_r(File.join(Rails.root, 'features', 'fixtures', 'bags', bag_name, 'data'),
                 local_staging_target)
  FileUtils.mv(File.join(local_staging_target, 'data'), File.join(local_staging_target, external_file_group.id.to_s))
  external_file_group.staged_file_location = File.join(staging_root.remote_path, external_file_group.collection.id.to_s, external_file_group.id.to_s)
  external_file_group.save!
end

And(/^the external file group with title '([^']*)' should have no staged content$/) do |title|
  external_file_group = ExternalFileGroup.find_by(title: title)
  expect(external_file_group.local_staged_file_location).to be_nil
end

And(/^the external file group with title '([^']*)' has a related bit level file group$/) do |title|
  external_file_group = ExternalFileGroup.find_by(title: title)
  bit_level_file_group = FactoryBot.create(:bit_level_file_group)
  external_file_group.target_file_groups << bit_level_file_group
end

Then(/^the external file group with title '([^']*)' should be in the process of ingestion$/) do |title|
  external_file_group = ExternalFileGroup.find_by(title: title)
  expect(external_file_group.workflow_ingest).to be_a(Workflow::Ingest)
end

And(/^the external file group with title '([^']*)' should not be in the process of ingestion$/) do |title|
  external_file_group = ExternalFileGroup.find_by(title: title)
  expect(external_file_group.workflow_ingest).to be_nil
end

And(/^the external file group with title '([^']*)' should have a related bit level file group titled '([^']*)' with relation note '([^']*)'$/) do |external_title, bit_level_title, note|
  external_file_group = ExternalFileGroup.find_by(title: external_title)
  bit_level_file_group = BitLevelFileGroup.find_by(title: bit_level_title)
  expect(external_file_group.target_file_groups).to include(bit_level_file_group)
  expect(external_file_group.target_file_group_joins.where(target_file_group_id: bit_level_file_group.id).first.note).to eq(note)
end

And(/^there should be a staging deletion job for the external file group titled '([^']*)'$/) do |title|
  external_file_group = ExternalFileGroup.find_by(title: title)
  expect(Job::IngestStagingDelete.find_by(external_file_group_id: external_file_group.id)).to be_truthy
end