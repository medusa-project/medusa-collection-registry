class CreateJobVirusScans < ActiveRecord::Migration
  def change
    create_table :job_virus_scans do |t|
      t.integer :file_group_id

      t.timestamps
    end
  end
end
