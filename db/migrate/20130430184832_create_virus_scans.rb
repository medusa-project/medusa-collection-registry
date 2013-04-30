class CreateVirusScans < ActiveRecord::Migration
  def change
    create_table :virus_scans do |t|
      t.integer :file_group_id
      t.text :scan_result

      t.timestamps
    end
    add_index :virus_scans, :file_group_id
  end
end
