class RenameProductionUnitToProducer < ActiveRecord::Migration
  def up
    rename_table :production_units, :producers
  end

  def down
    rename_table :producers, :production_units
  end
end
