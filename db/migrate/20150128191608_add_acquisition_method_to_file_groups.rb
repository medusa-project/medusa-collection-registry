class AddAcquisitionMethodToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :acquisition_method, :string
    add_index :file_groups, :acquisition_method
  end
end
