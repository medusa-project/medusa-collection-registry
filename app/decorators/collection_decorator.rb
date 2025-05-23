class CollectionDecorator < BaseDecorator

  def label
    object.title
  end

  def search_collection_link
    h.link_to(object.title, h.collection_path(object))
  end

  def events_path(args = {})
    h.events_collection_path(object, args)
  end

end