class StagingStorageRoot < Object
  attr_reader :local_path, :remote_path, :name

  def initialize(root_hash)
    @local_path = root_hash['local_path']
    @remote_path = root_hash['remote_path']
    @name = root_hash['name']
  end

  def directories_at(path)
    entries_at(path).select {|entry| entry.directory?}
  end

  def files_at(path)
    entries_at(path).select {|entry| entry.file?}
  end

  def entries_at(path)
    full_local_path_to(path).children
  end

  def full_local_path_to(relative_path)
    Pathname.new(File.join(local_path, relative_path))
  end

end
