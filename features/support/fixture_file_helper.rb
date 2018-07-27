module FixtureFileHelper

  module_function

  def storage_root
    @storage_root ||= initialize_storage_root
  end

  def initialize_storage_root
    MedusaStorage::Root::Filesystem.new(name: 'fixtures', type: 'filesystem',
                                       path: File.join(Rails.root, 'features', 'fixtures'))
  end

  def bag_key(bag_name)
    File.join('bags', bag_name, 'data')
  end

end