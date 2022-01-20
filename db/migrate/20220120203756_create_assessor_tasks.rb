class CreateAssessorTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :assessor_tasks do |t|
      t.references :cfs_file, foreign_key: true
      t.boolean :checksum
      t.boolean :mediatype
      t.boolean :fits

      t.timestamps
    end
  end
end
