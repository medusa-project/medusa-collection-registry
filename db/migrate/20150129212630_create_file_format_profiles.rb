class CreateFileFormatProfiles < ActiveRecord::Migration
  def change
    create_table :file_format_profiles do |t|
      t.string :name, null: false
      t.string :software
      t.string :software_version
      t.string :os_environment
      t.string :os_version
      t.text :notes

      t.timestamps null: false
    end
    add_index :file_format_profiles, :name, unique: true
  end
end
