class RemovePublishedAndOngoingFromCollections < ActiveRecord::Migration
  def change
    remove_columns :collections, :published, :ongoing
  end
end
