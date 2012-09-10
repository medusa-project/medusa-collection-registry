class DeleteContentTypeIdFromCollections < ActiveRecord::Migration
  def up
    remove_column :collections, :content_type_id
  end

  def down
    add_column :collections, :content_type_id, :integer, :index => true
  end
end
