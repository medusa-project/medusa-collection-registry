class CreateIdbIngestJobs < ActiveRecord::Migration
  def change
    create_table :idb_ingest_jobs do |t|
      t.string :uuid
      t.string :staging_path, null: false, unique: true
      t.timestamps null: false
    end
  end
end
