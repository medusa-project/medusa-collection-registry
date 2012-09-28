class FileGroup < ActiveRecord::Base
  attr_accessible :collection_id, :file_format, :file_location, :total_file_size, :total_files,
      :last_access_date, :producer_id, :storage_medium_id, :file_type_id, :summary, :provenance_note
  belongs_to :collection
  belongs_to :producer
  belongs_to :storage_medium
  belongs_to :file_type

  def file_type_name
    self.file_type.try(:name)
  end

  def storage_medium_name
    self.storage_medium.try(:name)
  end

end
