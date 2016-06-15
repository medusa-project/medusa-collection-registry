require 'singleton'

class AmqpAccrual::Config < Object
  include Singleton

  #attr_accessor :incoming_queue, :outgoing_queue, :idb_file_group_id, :staging_directory, :active
  attr_accessor :config

  def initialize
    self.config = YAML.load_file(File.join(Rails.root, 'config', 'amqp_accrual.yml'))[Rails.env]
  end

  ACCESSORS = [:incoming_queue, :outgoing_queue, :file_group_id, :staging_directory, :active, :delayed_job_queue,
               :return_directory_information, :allow_delete]

  ACCESSORS.each do |accessor|
    define_method(accessor) do |client|
      self.config[client.to_s][accessor.to_s]
    end
  end

  def all_queues(client)
    [self.incoming_queue(client), self.outgoing_queue(client)]
  end

  def file_group(client)
    BitLevelFileGroup.find(self.file_group_id(client))
  end

  def cfs_directory(client)
    file_group(client).cfs_directory
  end

  def active?(client)
    self.active(client)
  end

  def return_directory_information?(client)
    self.return_directory_information(client)
  end

  def allow_delete?(client)
    self.allow_delete(client)
  end

  #for testing we need this
  def set_file_group_id(client, id)
    self.config[client]['file_group_id'] = id
  end

  #for testing we need this
  def set_allow_delete(client, value)
    self.config[client]['allow_delete'] = value
  end

  def clients
    self.config.keys
  end

  DELEGATE_TO_INSTANCE = ACCESSORS + %i(all_queues file_group cfs_directory active? return_directory_information?
set_file_group_id set_allow_delete allow_delete? clients)

  def self.method_missing(method_name, *args)
    if DELEGATE_TO_INSTANCE.include?(method_name)
      self.instance.send(method_name, *args)
    else
      super
    end
  end

end
