class AddPrivateDescriptionToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :private_description, :text
  end
end
