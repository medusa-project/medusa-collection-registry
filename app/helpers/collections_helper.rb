module CollectionsHelper

  def content_type_select_collection
    ContentType.all.collect {|type| [type.name, type.id]}
  end

  def access_system_select_collection
    AccessSystem.all.collect {|system| [system.name, system.id]}
  end
end
