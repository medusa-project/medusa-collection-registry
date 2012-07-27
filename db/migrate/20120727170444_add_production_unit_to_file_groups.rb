class AddProductionUnitToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :production_unit_id, :integer, :index => true
  end
end
