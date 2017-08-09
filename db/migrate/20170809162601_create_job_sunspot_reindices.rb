class CreateJobSunspotReindices < ActiveRecord::Migration[5.1]
  def change
    create_table :job_sunspot_reindices do |t|
      t.integer :start_id
      t.integer :end_id
      t.integer :batch_size
      t.string :class_name

      t.timestamps
    end
  end
end
