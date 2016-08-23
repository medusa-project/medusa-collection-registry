class FileFormatTestDecorator < BaseDecorator

  delegate :file_group, :collection, :repository, to: :cfs_file
  [:file_group, :collection, :repository].each do |ancestor|
    delegate :id, :title, to: ancestor, prefix: true
  end
  delegate :acquisition_method, to: :file_group

  FitsData::all_fields.each do |field|
    delegate :"fits_data_#{field}", to: :cfs_file
  end

  def medusa_url
    "#{Settings.medusa.server}#{h.cfs_file_path(cfs_file)}"
  end

  def profile_name
    file_format_profile.name
  end

  def profile_name_simplified
    profile_name.sub(/\s*\(.*\)\s*$/, '')
  end

end
