class CfsFile < ActiveRecord::Base
  belongs_to :cfs_directory

  has_many :red_flags, :as => :red_flaggable, :dependent => :destroy

  validates_uniqueness_of :name, scope: :cfs_directory_id, allow_blank: false

  def repository
    self.cfs_directory.repository
  end

  def label
    self.relative_path
  end

  def cfs_label
    self.relative_path
  end

  def relative_path
    File.join(self.cfs_directory.relative_path, self.name)
  end

  def file_group
    self.cfs_directory.owning_file_group
  end

  def self.cfs_type
    'CFS File'
  end

  #the directories leading up to the file
  def ancestors
    self.cfs_directory.ancestors_and_self
  end

end