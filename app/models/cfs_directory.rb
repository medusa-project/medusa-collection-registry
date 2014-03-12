require 'pathname'
class CfsDirectory < ActiveRecord::Base

  has_many :subdirectories, class_name: 'CfsDirectory', :foreign_key => :parent_cfs_directory_id
  has_many :cfs_files
  belongs_to :parent_cfs_directory, class_name: 'CfsDirectory'
  has_one :file_group
  belongs_to :root_cfs_directory, class_name: 'CfsDirectory'

  validates :path, presence: true

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

  def repository
    self.file_group_root.file_group.repository
  end

  def file_group_root
    self.root_cfs_directory
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

  def relative_path
    if self.parent_cfs_directory.blank?
      self.path
    else
      File.join(self.parent_cfs_directory.relative_path, self.path)
    end
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

  protected

  def find_file_with_directory_components(file_name, path_components)
    directory = self.subdirectory_with_directory_components(path_components)
    directory.cfs_files.find_by(name: file_name) || (raise RuntimeError, 'File not found')
  end

  def subdirectory_with_directory_components(path_components)
    return self if path_components.blank?
    subdirectory_path = path_components.shift
    return self if subdirectory_path == '.'
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

end