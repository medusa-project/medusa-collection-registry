class CfsFileInfo < ActiveRecord::Base
  attr_accessible :fits_xml, :path

  validates_uniqueness_of :path, :allow_blank => false

  after_create :schedule_basic_assessment

  def schedule_basic_assessment
    self.delay.basic_assess
  end

  def basic_assess

  end

end
