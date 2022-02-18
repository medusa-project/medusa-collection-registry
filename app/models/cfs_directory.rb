require 'pathname'
require 'set'
class CfsDirectory < ApplicationRecord

  include Uuidable
  include Breadcrumb
  include Eventable
  include CascadedEventable
  include CascadedRedFlaggable
  include ExcludedFiles

  has_many :subdirectories, class_name: 'CfsDirectory', as: :parent, dependent: :destroy
  has_many :cfs_files, dependent: :destroy
  belongs_to :root_cfs_directory, class_name: 'CfsDirectory'
  has_many :archived_accrual_jobs, dependent: :destroy
  has_many :workflow_accrual_jobs, :class_name => 'Workflow::AccrualJob', dependent: :destroy
  belongs_to :parent, polymorphic: true, touch: true
  #This is only useful when you _know_ the object is a root cfs dir and the parent is therefore a file group. But
  #it's needed for some queries.
  belongs_to :parent_file_group, class_name: 'FileGroup', foreign_key: 'parent_id'
  has_one :job_cfs_initial_directory_assessment, :class_name => 'Job::CfsInitialDirectoryAssessment', dependent: :destroy

  validates :path, presence: true
  validates_uniqueness_of :path, scope: :parent_id, if: ->(record) {record.parent_type == 'CfsDirectory'}
  validate(unless: Proc.new {|record| record.parent_type == 'CfsDirectory'}) do |cfs_directory|
    unless (CfsDirectory.roots.where(path: cfs_directory.path).all - [cfs_directory]).empty?
      errors.add(:base, 'Path must be unique for roots')
    end
  end
  validates_inclusion_of :parent_type, in: %w(CfsDirectory FileGroup), allow_nil: true

  #two validations are needed because we can't set the root directory to self
  #until after we've saved once. The after_save callback sets this by default
  #after the initial save
  validates :root_cfs_directory_id, presence: true, if: ->(record) {record.parent_type == 'CfsDirectory'}
  validates :root_cfs_directory_id, presence: true, unless: ->(record) {record.parent_type == 'CfsDirectory'}, on: :update
  after_save :ensure_root
  after_update :handle_cfs_assessment

  breadcrumbs parent: :parent, label: :path
  cascades_events parent: :parent
  cascades_red_flags parent: :parent

  searchable include: {root_cfs_directory: {parent_file_group: :collection}} do
    integer :model_id, using: :id
    text :path
    string :path, stored: true
    string :collection_title do
      collection.try(:title)
    end
    string :file_group_title do
      file_group.try(:title)
    end
    integer :parent_id
    string :parent_type
  end

  #ensures that for FileGroup subclasses that we use FileGroup so that STI/polymorphism combination works properly
  def parent_type=(type)
    type = type.to_s.classify.constantize.base_class.to_s if type.present?
    super(type)
  end

  def self.roots
    where("parent_type IS NULL OR parent_type = 'FileGroup'")
  end

  def self.non_roots
    where("parent_type = 'CfsDirectory'")
  end

  def non_root?
    self.parent.is_a?(CfsDirectory)
  end

  def root?
    !self.non_root?
  end

  def is_empty?
    self.cfs_files.blank? and leaf?
  end

  def leaf?
    self.subdirectories.blank?
  end

  def is_empty_or_missing_on_storage?
    !is_present_and_populated_on_storage?
  end

  def is_present_and_populated_on_storage?
    storage_root.directory_key?(self.key) and storage_root.file_keys(self.key).present?
  rescue MedusaStorage::Error::InvalidDirectory
    false
  end

  #By all means think of a better name for this
  def pristine?
    self.is_empty? and self.is_empty_or_missing_on_storage?
  end

  def root
    self.root_cfs_directory
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
    self.root.parent.try(:repository)
  end

  def collection
    self.root.parent.try(:collection)
  end

  def file_group
    self.root.parent
  end

  #If the directory doesn't have a parent then it is a root, and this will set it if needed
  def ensure_root
    if self.root? and self.root_cfs_directory.blank?
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
    File.join(ancestors_and_self.collect {|d| d.path})
  end

  def key
    relative_path + '/'
  end

  def storage_root
    Application.storage_manager.main_root
  end

  def relative_path_from_root
    File.join(ancestors_and_self.collect {|d| d.path}.drop(1))
  end

  #list of all directories above this and self
  def ancestors_and_self
    self.ancestors << self
  end

  #list of all directories above this, excluding self
  def ancestors
    self.root? ? [] : self.parent.ancestors_and_self
  end

  #a list of all subdirectory ids in the tree under and including this directory
  def recursive_subdirectory_ids
    if self.root?
      CfsDirectory.where(root_cfs_directory_id: self.id).ids
    else
      ids = [self.id]
      while true
        new_ids = (CfsDirectory.non_roots.where(parent_id: ids).ids << self.id).sort
        return new_ids if ids == new_ids
        ids = new_ids
      end
    end
  end

  def timeline_directory_ids
    recursive_subdirectory_ids
  end

  def make_initial_entries
    subdirs = storage_subdirectories
    subdirs = subdirs.subtract(excluded_directories)
    subdirs.each do |dir|
      self.ensure_directory_at_relative_path(dir)
    end
    self.subdirectories.reload.each do |directory|
      unless subdirs.include?(directory.path)
        directory.destroy_tree_from_leaves
      end
    end
    files = storage_files
    files.each do |file|
      if excluded_file?(file)
        file_key = File.join(self.key, file)
        storage_root.delete_content(file_key) if storage_root.exist?(file_key)
      else
        self.ensure_file_at_relative_path(file)
      end
    end
    self.cfs_files.reload.each do |cfs_file|
      unless files.include?(cfs_file.name)
        cfs_file.destroy
      end
    end
  end

  def schedule_assessment_job
    Job::CfsInitialDirectoryAssessment.create_for(self, self.file_group) unless self.job_cfs_initial_directory_assessment.present?
  end

  def make_and_assess_tree
    schedule_assessment_job
  end

  def run_initial_assessment(recursive: true)
    make_initial_entries
    #TODO I might like to do this with Parallel, but my attempts have hung the tests for
    # reasons that are unclear to me [Howard]. This includes modifying the call to run_initial_assessment
    # so that the save happens in a mutex synchronized block.
    self.cfs_files.reload.each {|cfs_file| cfs_file.run_initial_assessment}
    self.subdirectories.reload.each {|subdirectory| subdirectory.schedule_assessment_job} if recursive
    Sunspot.commit
  end

  def handle_cfs_assessment
    #It is important to do the following in order

    #If the cfs directory had a present value for file_group_id before saving
    #and it changed then cancel the jobs in the old assessment.
    if parent_type_before_last_save == 'FileGroup' and saved_change_to_parent_id?
      Job::CfsInitialFileGroupAssessment.where(file_group_id: parent_id_before_last_save).each do |assessment|
        assessment.destroy_queued_jobs_and_self
      end
      Job::CfsInitialDirectoryAssessment.where(file_group_id: parent_id_before_last_save, cfs_directory_id: self.id).each do |assessment|
        assessment.destroy_queued_jobs_and_self
      end
    end
    #If there is a new, present value for file_group_id then schedule the cfs assessment
    if parent_type == 'FileGroup' and saved_change_to_parent_id?
      self.reload_parent.schedule_initial_cfs_assessment
    end
  end


  #recursively destroy the tree (including this directory) in the database from the bottom up
  #this has the advantage of not creating a giant transaction like self.destroy would because of
  #all of the association callbacks. Instead we descend to the leaves, destroy them and work up,
  #each time with just a little transaction. So this can also be interrupted and resumed.
  def destroy_tree_from_leaves
    self.subdirectories.each do |subdirectory|
      subdirectory.destroy_tree_from_leaves
    end
    self.subdirectories.reload
    self.cfs_files.each do |cfs_file|
      cfs_file.destroy!
    end
    self.cfs_files.reload
    self.destroy!
  end

  #yield each CfsDirectory in the tree to the block.
  def each_directory_in_tree(include_self: true)
    self.directories_in_tree(include_self: include_self).find_each do |directory|
      yield directory
    end
  end

  #yield each file in the tree to the block
  def each_file_in_tree
    self.directories_in_tree.find_each do |directory|
      next if directory.nil?
      directory.cfs_files.find_each do |cfs_file|
        next if cfs_file.nil?

        yield cfs_file if block_given?
      end
    end
  end

  def directories_in_tree(include_self: true)
    #for roots we can do this easily - for non roots we need to do it recursively
    directories = if self.root?
                    CfsDirectory.where(root_cfs_directory_id: self.id)
                  else
                    CfsDirectory.where(id: self.recursive_subdirectory_ids)
                  end
    if not include_self
      directories = directories.where('id != ?', self.id)
    end
    directories
  end

  def storage_files
    storage_root.file_keys(self.key).collect {|f| File.basename(f)}.to_set
  end

  def storage_subdirectories
    storage_root.subdirectory_keys(self.key).collect {|f| File.basename(f)}.to_set
  end

  def after_restore
    Sunspot.index self
    events.find_each do |event|
      event.recascade
    end
    events.reset
    cfs_files.find_each do |f|
      f.after_restore
    end
    cfs_files.reset
    subdirectories.find_each do |d|
      d.after_restore
    end
    subdirectories.reset
  end

  protected

  def find_file_with_directory_components(file_name, path_components)
    directory = self.subdirectory_with_directory_components(path_components)
    directory.cfs_files.find_by(name: file_name) || (raise RuntimeError, 'File not found')
  end

  def find_directory_with_directory_components(path_components)
    return self if path_components.blank?
    current_component = path_components.shift
    return self.find_directory_with_directory_components(path_components) if (current_component.blank? or (current_component == '.'))
    x = self.subdirectories.all.to_a
    subdirectory = self.subdirectories.find_by(path: current_component)
    if subdirectory
      return subdirectory.find_directory_with_directory_components(path_components)
    else
      raise RuntimeError, 'Path component not found'
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
                                                             parent: self, root_cfs_directory: self.root_cfs_directory)
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
                                                           parent: self, root_cfs_directory: self.root_cfs_directory)
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