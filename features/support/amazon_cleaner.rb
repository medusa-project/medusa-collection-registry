require 'fileutils'

#before each test make sure that the amazon bag directory is clean
Before do
  Dir[File.join(AmazonBackup.storage_root, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end
end
