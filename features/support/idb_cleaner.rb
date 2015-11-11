Before('@idb') do
  #clear idb staging directories - test should set these up as desired
  Dir[File.join(Idb::Config.instance.staging_directory, '*')].each do |dir|
    FileUtils.rm_rf(dir)
  end
  #clear idb queues
  AmqpConnector.instance.clear_queues(Idb::Config.instance.all_queues)
end