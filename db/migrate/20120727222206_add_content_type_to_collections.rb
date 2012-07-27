class AddContentTypeToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :content_type_id, :integer
    add_index :collections, :content_type_id
  end
end
