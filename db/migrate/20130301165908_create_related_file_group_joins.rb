class CreateRelatedFileGroupJoins < ActiveRecord::Migration
  def change
    create_table :related_file_group_joins do |t|
      t.integer :file_group_id
      t.integer :related_file_group_id
      t.string :note

      t.timestamps
    end
    add_index :related_file_group_joins, :file_group_id
    add_index :related_file_group_joins, :related_file_group_id
  end
end
