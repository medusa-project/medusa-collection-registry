Then(/^there should be (\d+) amazon backup delayed jobs?$/) do |count|
  expect(AmazonBackup.count).to eq(count.to_i)
end

And(/^I check all amazon backup checkboxes$/) do
  all('.amazon-backup-checkbox').each do |checkbox|
    checkbox.set(true)
  end
end

Then(/^the file group named '(.*)' should have a completed Amazon backup$/) do |name|
  bit_level_file_group = BitLevelFileGroup.find_by(name: name)
  expect(bit_level_file_group.last_amazon_backup.completed?).to be_truthy
end

When(/^I run a full Amazon backup for the file group named '(.*)'$/) do |name|
  file_group = BitLevelFileGroup.find_by(name: name)
  amazon_backup = AmazonBackup.create(user_id: User.first.id, cfs_directory_id: file_group.cfs_directory_id, date: Date.today)
  Job::AmazonBackup.create_for(amazon_backup)
  step "delayed jobs are run"
  step "amazon backup runs successfully"
end

When(/^amazon backup runs successfully$/) do
  Test::AmazonGlacierServer.instance.import_succeed
  AmazonBackupServerResponse.handle_responses
end