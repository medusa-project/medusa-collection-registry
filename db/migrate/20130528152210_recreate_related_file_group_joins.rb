class RecreateRelatedFileGroupJoins < ActiveRecord::Migration
  def up
    create_table :related_file_group_joins do |t|
      t.integer :source_file_group_id
      t.integer :target_file_group_id
      t.string :note

      t.timestamps
    end
    add_index :related_file_group_joins, :source_file_group_id
    add_index :related_file_group_joins, :target_file_group_id
  end

  def down
    drop_table :related_file_group_joins
  end
end
