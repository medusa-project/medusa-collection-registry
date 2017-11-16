class CreateFileFormatsFileFormatProfilesJoin < ActiveRecord::Migration[5.1]
  def change
    create_table :file_formats_file_format_profiles_joins do |t|
      t.references :file_format, foreign_key: true, index: {name: :ffffp_file_format_idx}
      t.references :file_format_profile, foreign_key: true, index: {name: :ffffp_file_format_profile_idx}
    end
    migrate_records_sql = <<SQL
      INSERT INTO file_formats_file_format_profiles_joins (file_format_id, file_format_profile_id)
      SELECT file_format_id, id FROM file_format_profiles WHERE file_format_id IS NOT NULL;
SQL
    ActiveRecord::Base.connection.execute(migrate_records_sql)
    remove_column :file_format_profiles, :file_format_id
  end
end
