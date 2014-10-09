require 'fileutils'

#before each test make sure that the amazon bag directory and AMQP queues are clean
Before do
  Dir[File.join(AmazonBackup.storage_root, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end
  Test::AmazonGlacierServer.instance.clear_queues
end

