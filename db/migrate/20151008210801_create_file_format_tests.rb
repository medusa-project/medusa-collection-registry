class CreateFileFormatTests < ActiveRecord::Migration
  def change
    create_table :file_format_tests do |t|
      t.references :cfs_file, index: true, foreign_key: true, null: false
      t.string :tester_email, null: false
      t.date :date, null: false
      t.boolean :pass, null: false, default: true
      t.text :notes, default: ''
      t.references :file_format_profile, index: true, foreign_key: true, null: false
    end
  end
end
