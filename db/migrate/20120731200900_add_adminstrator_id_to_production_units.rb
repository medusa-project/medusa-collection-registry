class AddAdminstratorIdToProductionUnits < ActiveRecord::Migration
  def change
    add_column :production_units, :administrator_id, :integer
    add_index :production_units, :administrator_id
  end
end
