class AddStorageMediumToFileGroup < ActiveRecord::Migration
  def change
    add_column :file_groups, :storage_medium_id, :integer
    add_index :file_groups, :storage_medium_id
  end
end
