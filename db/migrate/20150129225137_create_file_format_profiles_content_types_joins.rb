class CreateFileFormatProfilesContentTypesJoins < ActiveRecord::Migration
  def change
    create_table :file_format_profiles_content_types_joins do |t|
      t.references :file_format_profile
      t.references :content_type
      t.timestamps null: false
    end
    add_index :file_format_profiles_content_types_joins, :file_format_profile_id, name: :ffpctj_file_format_profile_id_idx
    add_index :file_format_profiles_content_types_joins, :content_type_id, name: :ffpctj_content_type_id_idx
    add_foreign_key :file_format_profiles_content_types_joins, :file_format_profiles
    add_foreign_key :file_format_profiles_content_types_joins, :content_types
  end
end
