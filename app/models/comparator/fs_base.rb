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

  #This is the method that should fill in the source only, target only, different sized paths appropriately
  #It should return self
  def analyze
    self
  end

  def objects_equal?
    source_only_paths.blank? and target_only_paths.blank? and different_sizes_paths.blank?
  end

  def augmented_source_only_paths
    augment_paths(source_only_paths)
  end

  def augmented_target_only_paths
    augment_paths(target_only_paths)
  end

  def augmented_different_sizes_paths
    augment_paths(different_sizes_paths)
  end

  protected

  #when appropriate gives a subclass a way to report the paths differently
  def augment_paths(path_collection)
    path_collection
  end

end