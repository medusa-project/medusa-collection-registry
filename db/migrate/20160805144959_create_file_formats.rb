class CreateFileFormats < ActiveRecord::Migration
  def change
    create_table :file_formats do |t|
      t.string :name, null: false
      t.string :pronom_id
      t.text :policy_summary

      t.timestamps null: false
    end
  end
end
