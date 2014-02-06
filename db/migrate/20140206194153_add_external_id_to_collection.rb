class AddExternalIdToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :external_id, :string
    add_index :collections, :external_id
  end
end
