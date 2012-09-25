class AddActiveDatesToProductionUnits < ActiveRecord::Migration
  def change
    add_column :production_units, :active_start_date, :date
    add_column :production_units, :active_end_date, :date
  end
end
