class CreateArchivedAccrualJobs < ActiveRecord::Migration
  def change
    create_table :archived_accrual_jobs do |t|
      t.text :report
      t.references :file_group, index: true, foreign_key: true
      t.references :amazon_backup, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :workflow_accrual_job_id, null: false, unique: true
      t.text :state, null: false
      t.text :staging_path, null: false
      t.references :cfs_directory, index: true, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
