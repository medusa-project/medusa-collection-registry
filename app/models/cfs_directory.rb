require 'pathname'
class CfsDirectory < ActiveRecord::Base

  has_many :subdirectories, class_name: 'CfsDirectory', foreign_key: :parent_cfs_directory_id, dependent: :destroy
  has_many :cfs_files, dependent: :destroy
  belongs_to :parent_cfs_directory, class_name: 'CfsDirectory'
  has_one :file_group
  belongs_to :root_cfs_directory, class_name: 'CfsDirectory'
  has_many :amazon_backups, -> { order 'date desc'}

  validates :path, presence: true
  validates_uniqueness_of :path, scope: :parent_cfs_directory_id

  #two validations are needed because we can't set the root directory to self
  #until after we've saved once. The after_save callback sets this by default
  #after the initial save
  validates :root_cfs_directory_id, presence: true, if: :parent_cfs_directory_id
  validates :root_cfs_directory_id, presence: true, unless: :parent_cfs_directory_id, on: :update
  after_save :ensure_root

  #ensure there is a CfsFile object at the given absolute path and return it
  def ensure_file_at_absolute_path(path)
    full_path = Pathname.new(path)
    relative_path = full_path.relative_path_from(Pathname.new(File.join(CfsRoot.instance.path, self.path)))
    ensure_file_at_relative_path(relative_path)
  end

  #ensure there is a CfsFile object at the given path relative to this directory's path and return it
  def ensure_file_at_relative_path(path)
    path_components = Pathname.new(path).split.collect(&:to_s)
    file_name = path_components.pop
    ensure_file_with_directory_components(file_name, path_components)
  end

  def ensure_directory_at_relative_path(path)
    path_components = Pathname.new(path).split.collect(&:to_s)
    ensure_directory_with_directory_components(path_components)
  end

  def repository
    self.file_group_root.file_group.repository
  end

  def file_group_root
    self.root_cfs_directory
  end

  def owning_file_group
    self.root_cfs_directory.file_group
  end

  #If the directory doesn't have a parent then it is a root, and this will set it if needed
  def ensure_root
    if self.parent_cfs_directory.blank? and self.root_cfs_directory.blank?
      self.root_cfs_directory = self
      self.save!
    end
  end

  def find_file_at_relative_path(path)
    path_components = Pathname.new(path).split.collect(&:to_s)
    file_name = path_components.pop
    find_file_with_directory_components(file_name, path_components)
  end

  def find_directory_at_relative_path(path)
    path_components = Pathname.new(path).split.collect(&:to_s)
    find_directory_with_directory_components(path_components)
  end

  def relative_path
    if self.parent_cfs_directory.blank?
      self.path
    else
      File.join(self.parent_cfs_directory.relative_path, self.path)
    end
  end

  def absolute_path
    File.join(CfsRoot.instance.path, self.relative_path)
  end

  #list of all directories above this and self
  def ancestors_and_self
    self.ancestors << self
  end

  #list of all directories above this, excluding self
  def ancestors
    self.file_group_root? ? [] : self.parent_cfs_directory.ancestors_and_self
  end

  def file_group_root?
    self.parent_cfs_directory.blank?
  end

  #a list of all subdirectory ids in the tree under and including this directory
  def recursive_subdirectory_ids
    if self.file_group_root?
      CfsDirectory.where(:root_cfs_directory_id => self.id).ids
    else
      #for the non root case we actually need to do some work, but we may not need this
      raise RuntimeError, "Not yet implemented"
    end
  end

  def make_initial_tree
    Dir.chdir(self.absolute_path) do
      #create the entire directory tree under this directory
      entries = ((Dir['*'] + Dir['.*']) - ['.', '..']).reject { |entry| File.symlink?(entry) }
      entries.select { |entry| File.file?(entry) }.each do |entry|
        self.ensure_file_at_relative_path(entry)
      end
      entries.select { |entry| File.directory?(entry) }.each do |entry|
        self.ensure_directory_at_relative_path(entry)
      end
    end
    self.subdirectories(true).each do |directory|
      directory.make_initial_tree
    end
  end

  def schedule_initial_assessments
    #walk the directory tree under and including this directory and schedule an
    #initial assessment for each directory
    self.each_directory_in_tree(true) do |directory|
      Job::CfsInitialDirectoryAssessment.create_for(directory, self.owning_file_group)
    end
  end

  def run_initial_assessment
    self.cfs_files.each do |cfs_file|
      cfs_file.run_initial_assessment
    end
  end

  def schedule_fits
    self.each_directory_in_tree(true) do |directory|
      Job::FitsDirectory.create_for(directory)
    end
  end

  def run_fits
    self.cfs_files.each do |cfs_file|
      cfs_file.ensure_fits_xml
    end
  end

  def self.export_root
    MedusaRails3::Application.medusa_config['cfs']['export_root']
  end

  def self.export_autoclean
    MedusaRails3::Application.medusa_config['cfs']['export_autoclean']
  end

  protected

  #yield each CfsDirectory in the tree to the block.
  def each_directory_in_tree(include_self = true)
    #for roots we can do this easily - for non roots we need to do it
    #recursively
    if self.file_group_root?
      directories = CfsDirectory.where(root_cfs_directory_id: self.id)
    else
      raise RuntimeError, 'Not yet implemented'
      #directories = ??
    end
    (directories = directories - [self]) unless include_self
    directories.each do |directory|
      yield directory
    end
  end

  def find_file_with_directory_components(file_name, path_components)
    directory = self.subdirectory_with_directory_components(path_components)
    directory.cfs_files.find_by(name: file_name) || (raise RuntimeError, 'File not found')
  end

  def find_directory_with_directory_components(path_components)
    return self if path_components.blank?
    current_component = path_components.pop
    return self.find_directory_with_directory_components(path_components) if (current_component.blank? or (current_component == '.'))
    subdirectory = self.subdirectories.find_by(path: current_component)
    if subdirectory
      return subdirectory.find_directory_with_directory_components(path_components)
    else
      raise RuntimeError, "Path component not found"
    end
  end

  def subdirectory_with_directory_components(path_components)
    return self if path_components.blank?
    subdirectory_path = path_components.shift
    return subdirectory_with_directory_components(path_components) if subdirectory_path == '.'
    subdirectory = self.subdirectories.find_by(path: subdirectory_path) || (raise RuntimeError, 'Subdirectory not found')
    subdirectory.subdirectory_with_directory_components(path_components)
  end

  def ensure_file_with_directory_components(file_name, path_components)
    if path_components.blank?
      self.cfs_files.find_or_create_by(:name => file_name)
    else
      subdirectory_path = path_components.shift
      if subdirectory_path == '.'
        self.ensure_file_with_directory_components(file_name, path_components)
      else
        subdirectory = self.subdirectories.find_or_create_by(:path => subdirectory_path,
                                                             :parent_cfs_directory => self, :root_cfs_directory => self.root_cfs_directory)
        subdirectory.ensure_file_with_directory_components(file_name, path_components)
      end
    end
  end

  def ensure_directory_with_directory_components(path_components)
    #do nothing if there are no path components
    return if path_components.blank?
    subdirectory_path = path_components.shift
    if subdirectory_path == '.'
      self.ensure_directory_with_directory_components(path_components)
    else
      subdirectory = self.subdirectories.find_or_create_by(:path => subdirectory_path,
                                                           :parent_cfs_directory => self, :root_cfs_directory => self.root_cfs_directory)
      subdirectory.ensure_directory_with_directory_components(path_components)
    end
  end

end