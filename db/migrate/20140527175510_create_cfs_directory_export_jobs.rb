class CreateCfsDirectoryExportJobs < ActiveRecord::Migration
  def change
    create_table :job_cfs_directory_exports do |t|
      t.integer :user_id
      t.integer :cfs_directory_id
      t.string :uuid
      t.boolean :recursive
    end
  end
end
