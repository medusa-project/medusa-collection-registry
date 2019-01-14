module ItemsHelper

  def items_equipment_collection
    [["<Leave blank>", ""]] + Item.equipment_types.zip(Item.equipment_types)
  end

  def items_source_media_collection
    [["<Leave blank>", ""]] + Item.source_media_types.zip(Item.source_media_types)
  end

  def items_statuses_collection
    [["<Leave blank>", ""]] + Item.statuses.zip(Item.statuses)
  end

end