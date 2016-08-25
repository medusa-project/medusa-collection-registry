class FileFormatDecorator < BaseDecorator

  def pronom_links
    object.pronoms.decorate.collect do |pronom|
      pronom.link
    end.join(', ')
  end

end