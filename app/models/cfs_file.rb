class CfsFile < ActiveRecord::Base
  belongs_to :cfs_directory

  has_many :red_flags, :as => :red_flaggable, :dependent => :destroy

  def repository
    self.cfs_directory.repository
  end

end