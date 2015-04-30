class StagingStorageRoot < Object
  attr_reader :local_path, :remote_path, :name

  def initialize(root_hash)
    @local_path = root_hash['local_path']
    @remote_path = root_hash['remote_path']
    @name = root_hash['name']
  end

end