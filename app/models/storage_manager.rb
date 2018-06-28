class StorageManager

  attr_accessor :main_root, :amqp_roots

  def initialize
    initialize_main_storage
    initialize_amqp_storage
  end

  def initialize_main_storage
    root_config = Settings.medusa.main_storage_root.to_h
    root_set = MedusaStorage::RootSet.new(Array.wrap(root_config))
    self.main_root = root_set.at(root_config[:name]) || raise('Main storage root not defined')
  end

  def initialize_amqp_storage

  end

  def amqp_root_at(name)

  end

end