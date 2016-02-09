class FileFormatTestDecorator < BaseDecorator

  delegate :file_group, :collection, :repository, to: :cfs_file
  [:file_group, :collection, :repository].each do |ancestor|
    delegate :id, :title, to: ancestor, prefix: true
  end
  delegate :acquisition_method, to: :file_group

  FitsData::ALL_FIELDS.each do |field|
    delegate :"fits_data_#{field}", to: :cfs_file
  end

  def medusa_url
    "#{MedusaCollectionRegistry::Application.medusa_config['server']}#{h.cfs_file_path(cfs_file)}"
  end


end
