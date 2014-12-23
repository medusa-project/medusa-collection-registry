class RenameAndAddFileGroupFields < ActiveRecord::Migration
  def change
    rename_column :file_groups, :name, :title
    rename_column :file_groups, :summary, :description
    add_column :file_groups, :private_description, :text
    add_column :file_groups, :access_url, :string
  end
end
