class CreateJobFitsFileExtensionBatches < ActiveRecord::Migration
  def change
    create_table :job_fits_file_extension_batches do |t|
      t.references :user, index: true
      t.references :file_extension, index: {:unique=>true}

      t.timestamps null: false
    end
    add_foreign_key :job_fits_file_extension_batches, :users
    add_foreign_key :job_fits_file_extension_batches, :file_extensions
  end
end
