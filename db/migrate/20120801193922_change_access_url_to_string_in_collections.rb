class ChangeAccessUrlToStringInCollections < ActiveRecord::Migration
  def up
    change_column :collections, :access_url, :string
  end

  def down
    change_column :collections, :access_url, :text
  end
end
