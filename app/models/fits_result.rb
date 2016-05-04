class FitsResult < ActiveRecord::Base
  belongs_to :cfs_file

  def class.storage_root
    Application.medusa_config.fits_storage
  end



end