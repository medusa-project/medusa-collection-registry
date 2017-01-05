class Comparator::FsBase < Object

  attr_accessor :source_directory, :target_directory, :source_only_paths,
                :target_only_paths, :different_sizes_paths


  def initialize(source_directory, target_directory)
    self.source_directory = source_directory
    self.target_directory = target_directory
    self.source_only_paths = Set.new
    self.target_only_paths = Set.new
    self.different_sizes_paths = Set.new
  end

end