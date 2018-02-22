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

end