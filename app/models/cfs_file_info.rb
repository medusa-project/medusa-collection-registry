class CfsFileInfo < ActiveRecord::Base
  attr_accessible :fits_xml, :path

  validates_uniqueness_of :path, :allow_blank => false

end
