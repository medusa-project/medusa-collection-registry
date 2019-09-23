module FixtureFileHelper

  module_function

  def storage_root
    @storage_root ||= initialize_storage_root
  end

  def initialize_storage_root
    MedusaStorage::Root::Filesystem.new(name: 'fixtures', type: 'filesystem',
                                       path: File.join(Rails.root, 'features', 'fixtures'))
  end

  #key to get just the data part of the bag
  def bag_key(bag_name)
    File.join(complete_bag_key(bag_name), 'data')
  end

  #key to get the entire bag
  def complete_bag_key(bag_name)
    File.join('bags', bag_name)
  end

end