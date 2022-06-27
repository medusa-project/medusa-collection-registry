require 'fileutils'

module IdbTestHelper
  module_function

  def idb_ingest_message
    {'operation' => 'ingest', 'staging_path' => 'prefix/test_dir/file.txt', 'pass_through' => {'key' => 'some value'}}
  end

  def idb_ingest_message_new_syntax
    {'operation' => 'ingest', 'staging_key' => 'prefix/test_dir/file.txt', 'target_key' => 'another/location/content.txt',
     'pass_through' => {'key' => 'some value'}}
  end

  def idb_delete_message
    {'operation' => 'delete', 'uuid' => 'c3712760-1183-0134-1d5b-0050569601ca-b', 'pass_through' => {'key' => 'some value'}}
  end

  def staging_key(message)
    message['staging_key'] || message['staging_path']
  end

  def stage_content(message)
    stage_content_to(staging_key(message), 'Staging text')
  end

  def stage_content_to(key, content_string)
    md5_sum = Digest::MD5.base64digest(content_string)
    storage_root = StorageManager.instance.amqp_root_at('idb')
    storage_root.copy_io_to(key, StringIO.new(content_string), md5_sum, content_string.length)
  end

end

Before('@idb') do
  #clear idb staging directories - test should set these up as desired
  StorageManager.instance.amqp_root_at('idb').delete_all_content
end

Around('@idb-no-deletions') do |scenario, block|
  old_value = AmqpAccrual::Config.allow_delete('idb')
  AmqpAccrual::Config.set_allow_delete('idb', false)
  block.call
  AmqpAccrual::Config.set_allow_delete('idb', old_value)
end
