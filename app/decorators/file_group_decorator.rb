class FileGroupDecorator < BaseDecorator

  def label
    object.title
  end

  def search_file_group_link
    h.link_to(object.title, h.file_group_path(object))
  end

  def events_path(args = {})
    h.events_file_group_path(object, args)
  end

end