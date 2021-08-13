class RenameProjectItemPermalinkToExternalLink < ActiveRecord::Migration[5.2]
  def change
    rename_column :items, :permalink, :external_link
  end
end
