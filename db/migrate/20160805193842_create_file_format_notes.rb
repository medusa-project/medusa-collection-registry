class CreateFileFormatNotes < ActiveRecord::Migration
  def change
    create_table :file_format_notes do |t|
      t.references :file_format, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.date :date, null: false
      t.text :note

      t.timestamps null: false
    end
  end
end
