class Comparator::SingleFile < Comparator::FsBase

  attr_accessor :filename

  def initialize(source_directory, target_directory, filename)
    super(source_directory, target_directory)
    self.filename = filename
  end

  def source_file
    @source_file ||= File.join(source_directory, filename)
  end

  def target_file
    @target_file ||= File.join(target_directory, filename)
  end

  def analyze
    raise RuntimeError, "Source file #{source_file} not found" unless File.exist?(source_file)
    if File.exist?(target_file)
      if File.size(source_file) != File.size(target_file)
        self.different_sizes_paths << filename
      end
    else
      self.source_only_paths << filename
    end
    self
  end

end