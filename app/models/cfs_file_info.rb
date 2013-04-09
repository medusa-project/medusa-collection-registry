class CfsFileInfo < ActiveRecord::Base
  attr_accessible :fits_xml, :path, :size, :md5_sum, :content_type

  validates_uniqueness_of :path, :allow_blank => false

  has_many :red_flags, :as => :red_flaggable, :dependent => :destroy

  #check each instance to see if the given path is still valid - if not then
  #remove it
  def self.remove_orphans(url_path = '')
    paths = self.where("path LIKE ?", url_path + "%").pluck(:path)
    paths.each do |path|
      file_path = Cfs.file_path_for(path)
      unless File.exists?(file_path)
        CfsFileInfo.find_by_path(path).destroy
      end
    end
  end

end
