class RemoveIdbIngestJobs < ActiveRecord::Migration
  def change
    drop_table :idb_ingest_jobs
  end
end
