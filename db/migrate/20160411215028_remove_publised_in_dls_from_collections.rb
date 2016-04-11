class RemovePublisedInDlsFromCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :published_in_dls
  end
end
