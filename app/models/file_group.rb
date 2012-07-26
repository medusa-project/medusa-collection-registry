class FileGroup < ActiveRecord::Base
  attr_accessible :collection_id, :file_format, :file_location, :total_file_size, :total_files,
      :last_access_date
  belongs_to :collection
end
