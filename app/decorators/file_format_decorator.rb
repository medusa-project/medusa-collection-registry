class FileFormatDecorator < BaseDecorator

  def pronom_links
    object.pronoms.decorate.collect do |pronom|
      pronom.link
    end.join(', ').html_safe
  end

  def extensions_string
    logical_extensions.collect do |extension|
      extension.label
    end.join(', ')
  end

  def related_file_formats_links
    object.related_file_formats.order(:name).collect do |related_file_format|
      h.link_to(related_file_format.name, related_file_format)
    end.join(', ')
  end

end