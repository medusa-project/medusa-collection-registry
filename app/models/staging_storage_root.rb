class StagingStorageRoot < Object
  attr_reader :local_path, :remote_path

  def initialize(root_hash)
    @local_path = root_hash['local_path']
    @remote_path = root_hash['remote_path']
  end

end