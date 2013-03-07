require 'utils/luhn'

class BitFile < ActiveRecord::Base
  attr_accessible :content_type, :directory_id, :dx_ingested, :dx_name, :md5sum, :name, :size
  belongs_to :directory
  before_create :assign_uuid
  before_destroy :not_dx_ingested

  validates_presence_of :directory_id, :name
  validates_uniqueness_of :name, :scope => :directory_id
  validates_uniqueness_of :dx_name

  def assign_uuid
    self.dx_name ||= Utils::Luhn.generate_checked_uuid
  end

  def full_delete
    self.dx_delete(false)
    self.destroy
  end

  def dx_delete(save = true)
    Dx.instance.delete_file(self)
    self.dx_ingested = false
    self.save if save
  end

  def not_dx_ingested
    !self.dx_ingested
  end

  def dx_url
    Dx.instance.file_url(self)
  end

  def file_group
    self.directory.file_group
  end

  def ensure_fits_xml
    self.update_fits_xml if self.fits_xml.blank? and self.dx_ingested
  end

  if Rails.env == 'test'
    def update_fits_xml
      self.fits_xml = File.read(File.join('features', 'fixtures', 'fits.xml'))
      self.save!
    end
  else
    def update_fits_xml
      if self.dx_ingested
        self.fits_xml = Dx.instance.get_fits_for(self)
        self.save!
      end
    end
  end

end
