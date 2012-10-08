class FileGroup < ActiveRecord::Base
  attr_accessible :collection_id, :file_format, :file_location, :total_file_size, :total_files,
      :last_access_date, :producer_id, :storage_medium_id, :file_type_id, :summary, :provenance_note,
      :collection_attributes
  belongs_to :collection
  belongs_to :producer
  belongs_to :storage_medium
  belongs_to :file_type
  accepts_nested_attributes_for :collection

  [:naming_conventions, :file_hierarchy, :file_types, :origin, :misc_notes].each do |field|
    auto_html_for field do
      html_escape
      link :target => "_blank"
      simple_format
    end
  end

  def file_type_name
    self.file_type.try(:name)
  end

  def storage_medium_name
    self.storage_medium.try(:name)
  end

end
