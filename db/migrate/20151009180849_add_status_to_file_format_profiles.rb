class AddStatusToFileFormatProfiles < ActiveRecord::Migration
  def change
    add_column :file_format_profiles, :status, :string, null: false, default: 'active', index: true
    FileFormatProfile.find_each {|profile| profile.status = 'active' ; profile.save!}
  end
end
