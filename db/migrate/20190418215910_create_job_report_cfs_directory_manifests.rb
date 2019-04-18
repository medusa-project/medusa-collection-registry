class CreateJobReportCfsDirectoryManifests < ActiveRecord::Migration[5.2]
  def change
    create_table :job_report_cfs_directory_manifests do |t|
      t.references :user, foreign_key: true
      t.references :cfs_directory, foreign_key: true

      t.timestamps
    end
  end
end
