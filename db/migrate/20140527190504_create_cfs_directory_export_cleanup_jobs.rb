class CreateCfsDirectoryExportCleanupJobs < ActiveRecord::Migration
  def change
    create_table :job_cfs_directory_export_cleanups do |t|
      t.string :directory
    end
  end
end
