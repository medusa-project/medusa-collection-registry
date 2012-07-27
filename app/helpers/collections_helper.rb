module CollectionsHelper

  def content_type_select_collection
    ContentType.all.collect {|type| [type.name, type.id]}
  end
end
