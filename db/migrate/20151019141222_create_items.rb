class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :project, index: true, foreign_key: true
      t.string :barcode, index: true, null: false
      t.string :bib_id, index: true
      t.string :oclc_number, index: true
      t.string :call_number, index: true
      t.string :book_name
      t.string :title
      t.string :author
      t.string :imprint
      t.date :photo_date
      t.text :special_notes
      t.boolean :tif_completed, null: false, default: false
      t.boolean :qa_tif, null: false, default: false
      t.boolean :transferred_to_medusa, null: false, default: false
      t.boolean :transferred_to_hathi, null: false, default: false

      t.timestamps null: false
    end
  end
end
