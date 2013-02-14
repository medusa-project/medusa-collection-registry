module FileGroupsHelper

  def producers_select_collection
    Producer.order(:title).all.collect do |producer|
      [producer.title, producer.id]
    end
  end

  def file_types_select_collection
    FileType.order(:name).all.collect do |type|
      [type.name, type.id]
    end
  end
end
