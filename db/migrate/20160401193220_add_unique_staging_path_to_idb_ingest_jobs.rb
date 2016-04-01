class AddUniqueStagingPathToIdbIngestJobs < ActiveRecord::Migration
  def change
    add_index :idb_ingest_jobs, :staging_path, unique: true
  end
end
