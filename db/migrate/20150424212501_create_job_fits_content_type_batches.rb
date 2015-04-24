class CreateJobFitsContentTypeBatches < ActiveRecord::Migration
  def change
    create_table :job_fits_content_type_batches do |t|
      t.references :user, index: true
      t.references :content_type, index: {:unique=>true}

      t.timestamps null: false
    end
    add_foreign_key :job_fits_content_type_batches, :users
    add_foreign_key :job_fits_content_type_batches, :content_types
  end
end
