class CfsFileInfo < ActiveRecord::Base
  validates_uniqueness_of :path, :allow_blank => false

  has_many :red_flags, :as => :red_flaggable, :dependent => :destroy

  #check each instance to see if the given path is still valid - if not then
  #remove it
  def self.remove_orphans(url_path = '')
    paths = self.all_for_path(url_path).pluck(:path)
    paths.each do |path|
      file_path = Cfs.file_path_for(path)
      unless File.exists?(file_path)
        CfsFileInfo.find_by_path(path).destroy
      end
    end
  end

  def self.all_for_path(url_path = '')
    self.where("path LIKE ?", url_path + "/%")
  end

  def self.cfs_type
    'CFS File'
  end

  def cfs_label
    self.path
  end

  def label
    self.path
  end

  def file_group
    FileGroup.where('cfs_root IS NOT NULL').where("? LIKE cfs_root || ?", self.path, "/%").first
  end

  def repository
    self.file_group.repository
  end

end
