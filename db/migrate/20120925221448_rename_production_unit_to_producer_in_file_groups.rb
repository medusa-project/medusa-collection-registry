class RenameProductionUnitToProducerInFileGroups < ActiveRecord::Migration
  def up
    rename_column :file_groups, :production_unit_id, :producer_id
  end

  def down
    rename_column :file_groups, :producer_id, :production_unit_id
  end
end
