require 'fileutils'

module IdbTestHelper
  module_function

  def idb_ingest_message
    {'operation' => 'ingest', 'staging_path' => 'prefix/test_dir/file.txt'}
  end

  def idb_delete_message
    {'operation' => 'delete', 'uuid' => 'c3712760-1183-0134-1d5b-0050569601ca-b'}
  end

  def staging_path
    idb_ingest_message['staging_path']
  end

  def stage_content
    path = File.join(AmqpAccrual::Config.staging_directory('idb'), staging_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') do |f|
      f.puts "Staging text"
    end
  end

end

Before('@idb') do
  #clear idb staging directories - test should set these up as desired
  Dir[File.join(AmqpAccrual::Config.staging_directory('idb'), '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end
  #clear idb queues
  AmqpConnector.connector(:medusa).clear_queues(AmqpAccrual::Config.all_queues('idb'))
end