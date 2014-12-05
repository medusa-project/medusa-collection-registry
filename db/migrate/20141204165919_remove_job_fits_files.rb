class RemoveJobFitsFiles < ActiveRecord::Migration
  def change
    drop_table :job_fits_files
  end
end
