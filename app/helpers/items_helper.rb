module ItemsHelper

  def mass_edit_equipment_collection
    [["<Leave blank>", ""]] + Item.equipment_types.zip(Item.equipment_types)
  end

end