require 'pathname'
class CfsDirectory < ActiveRecord::Base
  include Uuidable
  include Breadcrumb
  include CascadedEventable

  has_many :subdirectories, class_name: 'CfsDirectory', foreign_key: :parent_cfs_directory_id, dependent: :destroy
  has_many :cfs_files, dependent: :destroy
  belongs_to :parent_cfs_directory, class_name: 'CfsDirectory', touch: true
  belongs_to :file_group, touch: true
  belongs_to :root_cfs_directory, class_name: 'CfsDirectory'
  has_many :amazon_backups, -> { order 'date desc' }

  validates :path, presence: true
  validates_uniqueness_of :path, scope: :parent_cfs_directory_id, if: :parent_cfs_directory_id
  validate(unless: :parent_cfs_directory_id) do |cfs_directory|
    unless (CfsDirectory.where(path: cfs_directory.path).where('parent_cfs_directory_id IS NULL').all - [cfs_directory]).empty?
      errors.add(:base, "Path must be unique for roots")
    end
  end
  validate do |cfs_directory|
    if cfs_directory.parent_cfs_directory_id.present? and cfs_directory.file_group_id.present?
      errors.add(:base, "Only root directories can be associated to a file group.")
    end
  end
  #two validations are needed because we can't set the root directory to self
  #until after we've saved once. The after_save callback sets this by default
  #after the initial save
  validates :root_cfs_directory_id, presence: true, if: :parent_cfs_directory_id
  validates :root_cfs_directory_id, presence: true, unless: :parent_cfs_directory_id, on: :update
  after_save :ensure_root
  after_save :handle_cfs_assessment

  breadcrumbs parent: :parent, label: :path
  cascades_events parent: :parent

  def self.roots
    where('parent_cfs_directory_id IS NULL')
  end

  #ensure there is a CfsFile object at the given absolute path and return it
  def ensure_file_at_absolute_path(path)
    full_path = Pathname.new(path)
    relative_path = full_path.relative_path_from(Pathname.new(File.join(CfsRoot.instance.path, self.path)))
    ensure_file_at_relative_path(relative_path)
  end

  #ensure there is a CfsFile object at the given path relative to this directory's path and return it
  def ensure_file_at_relative_path(path)
    path_components = fully_split_path(path)
    file_name = path_components.pop
    ensure_file_with_directory_components(file_name, path_components)
  end

  def ensure_directory_at_relative_path(path)
    path_components = fully_split_path(path)
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
    true
  end

  def find_file_at_relative_path(path)
    path_components = fully_split_path(path)
    file_name = path_components.pop
    find_file_with_directory_components(file_name, path_components)
  end

  def find_directory_at_relative_path(path)
    path_components = fully_split_path(path)
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
      CfsDirectory.where(root_cfs_directory_id: self.id).ids
    else
      ids = [self.id]
      while true
        new_ids = (CfsDirectory.where(parent_cfs_directory_id: ids).ids << self.id).sort
        return new_ids if ids == new_ids
        ids = new_ids
      end
    end
  end

  def make_initial_tree
    Dir.chdir(self.absolute_path) do
      #create the entire directory tree under this directory
      entries = ((Dir['*'] + Dir['.*']) - ['.', '..']).reject { |entry| File.symlink?(entry) }
      disk_directories = entries.select { |entry| File.directory?(entry) }.to_set
      disk_directories.each do |entry|
        self.ensure_directory_at_relative_path(entry)
      end
      self.subdirectories.reload.each do |directory|
        unless disk_directories.include?(directory.path)
          directory.destroy
        end
      end
      self.subdirectories.reload.each do |directory|
        directory.make_initial_tree
      end
      disk_files = entries.select { |entry| File.file?(entry) }.to_set
      disk_files.each do |entry|
        self.ensure_file_at_relative_path(entry)
      end
      self.cfs_files.reload.each do |cfs_file|
        unless disk_files.include?(cfs_file.name)
          cfs_file.destroy
        end
      end
      #We do this to free up the subdirectories and files for GC. I think it should do so.
      self.subdirectories.reset
      self.cfs_files.reset
    end
  end

  def schedule_initial_assessments
    #walk the directory tree under and including this directory and schedule an
    #initial assessment for each directory
    self.each_directory_in_tree(true) do |directory|
      Job::CfsInitialDirectoryAssessment.create_for(directory, self.owning_file_group) unless directory.cfs_files.count == 0
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

  def public?
    self.owning_file_group.try(:public?)
  end

  def update_tree_stats(count_difference, size_difference)
    self.tree_count += count_difference
    self.tree_size += size_difference
    self.save!
    if self.file_group_root?
      self.owning_file_group.refresh_file_stats if self.owning_file_group.present?
    else
      self.parent_cfs_directory.update_tree_stats(count_difference, size_difference)
    end
  end

  def update_tree_stats_from_db
    self.tree_size = self.subdirectories.sum(:tree_size) + self.cfs_files.sum(:size)
    self.tree_count = self.subdirectories.sum(:tree_count) + self.cfs_files.count
    self.save!
    if self.file_group_root?
      self.owning_file_group.refresh_file_stats if self.owning_file_group.present?
    else
      self.parent_cfs_directory.update_tree_stats_from_db
    end
  end

  def update_all_tree_stats_from_db
    root = self.root_cfs_directory
    leaves = CfsDirectory.where(root_cfs_directory_id: root.id).all.select { |cfs_directory| cfs_directory.subdirectories.blank? }
    leaves.each { |leaf| leaf.update_tree_stats_from_db }
  end

  def self.update_all_tree_stats_from_db
    roots = self.where('parent_cfs_directory_id IS NULL')
    roots.each { |root| root.update_all_tree_stats_from_db }
  end

  def handle_cfs_assessment
    #It is important to do the following in order

    #If the cfs directory had a present value for file_group_id before saving
    #and it changed then cancel the jobs in the old assessment.
    if file_group_id_was.present? and file_group_id_changed?
      Job::CfsInitialFileGroupAssessment.where(file_group_id: file_group_id_was).each do |assessment|
        assessment.destroy_queued_jobs_and_self
      end
      Job::CfsInitialDirectoryAssessment.where(file_group_id: file_group_id_was, cfs_directory_id: self.id).each do |assessment|
        assessment.destroy_queued_jobs_and_self
      end
    end
    #If there is a new, present value for file_group_id then schedule the cfs assessment
    if file_group_id.present? and file_group_id_changed?
      self.file_group.schedule_initial_cfs_assessment
    end
    true
  end

  def parent
    self.parent_cfs_directory || self.file_group
  end

  #recursively destroy the tree (including this directory) in the database from the bottom up
  #this has the advantage of not creating a giant transaction like self.destroy would because of
  #all of the association callbacks. Instead we descend to the leaves, destroy them and work up,
  #each time with just a little transaction. So this can also be interrupted and resumed.
  def destroy_tree_from_leaves
    self.subdirectories.each do |subdirectory|
      subdirectory.destroy_tree_from_leaves
    end
    self.subdirectories(true)
    self.cfs_files.each do |cfs_file|
      cfs_file.destroy!
    end
    self.cfs_files(true)
    self.destroy!
  end

  #yield each CfsDirectory in the tree to the block.
  def each_directory_in_tree(include_self = true)
    self.directories_in_tree(include_self).each do |directory|
      yield directory
    end
  end

  #yield each file in the tree to the block
  def each_file_in_tree
    self.directories_in_tree.find_all.each do |directory|
      directory.cfs_files.each do |cfs_file|
        yield cfs_file
      end
    end
  end

  def directories_in_tree(include_self = true)
    #for roots we can do this easily - for non roots we need to do it recursively
    directories = if self.file_group_root?
                    CfsDirectory.where(root_cfs_directory_id: self.id)
                  else
                    CfsDirectory.where(id: self.recursive_subdirectory_ids)
                  end
    (directories = directories - [self]) unless include_self
    directories
  end

  def supported_event_hash
    @@supported_event_hash ||= read_event_hash(:cfs_directory)
  end

  protected

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
      self.cfs_files.find_or_create_by(name: file_name)
    else
      subdirectory_path = path_components.shift
      if subdirectory_path == '.'
        self.ensure_file_with_directory_components(file_name, path_components)
      else
        subdirectory = self.subdirectories.find_or_create_by(path: subdirectory_path,
                                                             parent_cfs_directory: self, root_cfs_directory: self.root_cfs_directory)
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
      subdirectory = self.subdirectories.find_or_create_by(path: subdirectory_path,
                                                           parent_cfs_directory: self, root_cfs_directory: self.root_cfs_directory)
      subdirectory.ensure_directory_with_directory_components(path_components)
    end
  end

  #separate completely into components
  def fully_split_pathname(pathname, accumulator = nil)
    accumulator ||= Array.new
    rest, last = pathname.split
    accumulator << last.to_s
    if rest.to_s == '.'
      return accumulator.reverse
    else
      return fully_split_pathname(rest, accumulator)
    end
  end

  def fully_split_path(path)
    fully_split_pathname(Pathname.new(path))
  end

end