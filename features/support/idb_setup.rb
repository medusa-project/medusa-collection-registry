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
    #TODO remove old code
    # path = File.join(AmqpAccrual::Config.staging_directory('idb'), staging_path)
    # FileUtils.mkdir_p(File.dirname(path))
    # File.open(path, 'w') do |f|
    #   f.puts 'Staging text'
    # end
    text = 'Staging text'
    md5_sum = Digest::MD5.base64digest(text)
    storage_root = AmqpAccrual::Config.instance.storage_roots.at('idb')
    storage_root.copy_io_to(staging_path, StringIO.new(text), md5_sum, text.length)
  end

end

Before('@idb') do
  #clear idb staging directories - test should set these up as desired
  AmqpAccrual::Config.instance.storage_roots.at('idb').delete_all_content
end

Around('@idb-no-deletions') do |scenario, block|
  old_value = AmqpAccrual::Config.allow_delete('idb')
  AmqpAccrual::Config.set_allow_delete('idb', false)
  block.call
  AmqpAccrual::Config.set_allow_delete('idb', old_value)
end
