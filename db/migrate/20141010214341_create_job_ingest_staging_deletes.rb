class CreateJobIngestStagingDeletes < ActiveRecord::Migration
  def change
    create_table :job_ingest_staging_deletes do |t|
      t.references :external_file_group, index: true
      t.references :user, index: true
      t.text :path
    end
  end
end
