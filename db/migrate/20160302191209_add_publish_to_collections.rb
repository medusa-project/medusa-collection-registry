class AddPublishToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :publish, :boolean, default: false
    add_index :collections, :publish
  end
end
