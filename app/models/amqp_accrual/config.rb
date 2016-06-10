require 'singleton'

class AmqpAccrual::Config < Object
  include Singleton

  attr_accessor :incoming_queue, :outgoing_queue, :idb_file_group_id, :staging_directory, :active

  def initialize
    config = YAML.load_file(File.join(Rails.root, 'config', 'idb.yml'))[Rails.env]
    self.incoming_queue ||= config['incoming_queue']
    self.outgoing_queue ||= config['outgoing_queue']
    self.idb_file_group_id ||= config['idb_file_group_id']
    self.staging_directory ||= config['staging_directory']
    self.active ||= config['active']
  end

  def all_queues
    [self.incoming_queue, self.outgoing_queue]
  end

  def idb_file_group
    BitLevelFileGroup.find(self.idb_file_group_id)
  end

  def idb_cfs_directory
    idb_file_group.cfs_directory
  end

  def active?
    self.active
  end

end
