class FileFormatTest < ActiveRecord::Base

  belongs_to :cfs_file
  belongs_to :file_format_profile

end