class CreateFileFormatProfilesFileExtensionsJoins < ActiveRecord::Migration
  def change
    create_table :file_format_profiles_file_extensions_joins do |t|
      t.references :file_format_profile
      t.references :file_extension
      t.timestamps null: false
    end
    add_index :file_format_profiles_file_extensions_joins, :file_format_profile_id, name: :ffpfej_file_format_profile_id_idx
    add_index :file_format_profiles_file_extensions_joins, :file_extension_id, name: :ffpfej_file_extension_id_idx
    add_foreign_key :file_format_profiles_file_extensions_joins, :file_format_profiles
    add_foreign_key :file_format_profiles_file_extensions_joins, :file_extensions
  end
end
