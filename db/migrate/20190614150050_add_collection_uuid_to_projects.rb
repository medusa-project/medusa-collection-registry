class AddCollectionUuidToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :collection_uuid, :string
    add_index :projects, :collection_uuid
    Project.all.each do |project|
      project.collection_uuid = project.collection.uuid
      project.save!
    end
  end
end
