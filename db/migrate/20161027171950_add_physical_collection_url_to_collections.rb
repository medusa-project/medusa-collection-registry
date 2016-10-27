class AddPhysicalCollectionUrlToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :physical_collection_url, :string
  end
end
