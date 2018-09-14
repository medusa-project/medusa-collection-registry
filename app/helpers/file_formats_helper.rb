module FileFormatsHelper

  def potential_related_file_formats(file_format)
    query = FileFormat.order(:name)
    query = query.where('id != ?', file_format.id) if file_format.id.present?
    query
  end

end