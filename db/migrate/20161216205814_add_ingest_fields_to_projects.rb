class AddIngestFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ingest_folder, :string
    add_column :projects, :destination_folder_uuid, :string
  end
end
