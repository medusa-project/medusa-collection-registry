class AddContactToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :contact_id, :integer
    add_index :collections, :contact_id
  end
end
