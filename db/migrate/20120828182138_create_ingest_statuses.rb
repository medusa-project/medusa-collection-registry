class CreateIngestStatuses < ActiveRecord::Migration
  def change
    create_table :ingest_statuses do |t|
      t.string :state
      t.string :staff
      t.date :date
      t.text :notes
      t.integer :collection_id

      t.timestamps
    end
  end
end
