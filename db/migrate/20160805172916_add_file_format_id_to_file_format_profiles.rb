class AddFileFormatIdToFileFormatProfiles < ActiveRecord::Migration
  def change
    add_column :file_format_profiles, :file_format_id, :integer
    add_index :file_format_profiles, :file_format_id
  end
end
