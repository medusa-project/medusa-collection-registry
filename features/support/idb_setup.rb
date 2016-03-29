require 'fileutils'

module IdbTestHelper
  module_function

  def idb_ingest_message
    {'operation' => 'ingest', 'staging_path' => 'prefix/test_dir/file.txt'}
  end

  def staging_path
    idb_ingest_message['staging_path']
  end

  def stage_content
    path = File.join(Idb::Config.instance.staging_directory, staging_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') do |f|
      f.puts "Staging text"
    end
  end

end

Before('@idb') do
  #clear idb staging directories - test should set these up as desired
  Dir[File.join(Idb::Config.instance.staging_directory, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end
  #clear idb queues
  AmqpConnector.instance.clear_queues(Idb::Config.instance.all_queues)
end