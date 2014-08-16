And(/^there should be (\d+) Amazon backup manifests?$/) do |count|
  expect(Dir[File.join(AmazonBackup.manifest_directory, '*')].size).to eq(count.to_i)
end

And(/^there should be (\d+) Amazon backup bags?$/) do |count|
  expect(Dir[File.join(AmazonBackup.global_bag_directory, '*')].size).to eq(count.to_i)
end

When(/^I create Amazon bags for the cfs directory with path '(.*)'$/) do |path|
  cfs_directory = CfsDirectory.where(path: path).first
  user = FactoryGirl.create(:user)
  amazon_backup = AmazonBackup.new(cfs_directory: cfs_directory, date: Date.today, user: user)
  amazon_backup.save!
  amazon_backup.make_backup_bags
end

And(/^all the data of bag '(.*)' should be in some Amazon backup bag$/) do |bag_name|
  bag_directory = bag_path(bag_name)
  files = Dir.chdir(File.join(bag_directory, 'data')) do
    Dir['**/*'].select {|file| File.file?(file)}
  end
  Dir.chdir(AmazonBackup.global_bag_directory) do
    bag_dirs = Dir['dir*']
    files.each do |file|
      containing_dir = bag_dirs.detect do |dir|
        File.exists?(File.join(dir, 'data', file))
      end
      expect(containing_dir).to be_truthy
    end
  end
end

Then(/^there should be (\d+) amazon backup delayed jobs?$/) do |count|
  expect(AmazonBackup.count).to eq(count.to_i)
end

And(/^I check all amazon backup checkboxes$/) do
  all('.amazon-backup-checkbox').each do |checkbox|
    checkbox.set(true)
  end
end