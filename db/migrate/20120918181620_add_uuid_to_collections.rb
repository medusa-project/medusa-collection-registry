class AddUuidToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :uuid, :string
    add_index :collections, :uuid
  end
end
