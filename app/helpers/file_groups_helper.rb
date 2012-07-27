module FileGroupsHelper

  def production_units_select_collection
    ProductionUnit.order(:title).all.collect do |production_unit|
      [production_unit.title, production_unit.id]
    end
  end
end
