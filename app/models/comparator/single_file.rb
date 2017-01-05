class Comparator::SingleFile < Comparator::FsBase

  attr_accessor :source_directory, :target_directory, :filename, :source_only_paths,
                :target_only_paths, :different_sizes_paths

  def initialize(source_directory, target_directory, filename)
    self.source_directory = source_directory
    self.target_directory = target_directory
    self.filename = filename
    self.source_only_paths = Set.new
    self.target_only_paths = Set.new
    self.different_sizes_paths = Set.new
    self.analyze
  end

  def source_file
    File.join(source_directory, filename)
  end

  def target_file
    File.join(target_directory, filename)
  end

  def analyze
    source_exists = File.exist?(source_file)
    target_exists = File.exist?(target_file)
    raise RuntimeError, "Source file #{source_file} not found" unless source_exists
    if target_exists
      if File.size(source_file) != File.size(target_file)
        self.different_sizes_paths << filename
      end
    else
      self.source_only_paths << filename
    end
  end

  def objects_equal?
    source_only_paths.blank? and target_only_paths.blank? and different_sizes_paths.blank?
  end

  def augmented_source_only_paths
    source_only_paths
  end

  def augmented_target_only_paths
    target_only_paths
  end

  def augmented_different_size_paths
    different_sizes_paths
  end

end