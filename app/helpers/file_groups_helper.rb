module FileGroupsHelper

  def production_units_select_collection
    ProductionUnit.order(:title).all.collect do |production_unit|
      [production_unit.title, production_unit.id]
    end
  end

  def storage_media_select_collection
    StorageMedium.all.collect do |medium|
      [medium.name, medium.id]
    end
  end

  def file_types_select_collection
    FileType.all.collect do |type|
      [type.name, type.id]
    end
  end
end
