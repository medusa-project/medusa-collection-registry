class RemoveRightsFieldsFromCollections < ActiveRecord::Migration
  def up
    remove_columns :collections, :rights_statement, :rights_restrictions
  end

  def down
    add_column :collections, :rights_statement, :text
    add_column :collections, :rights_restrictions, :text
  end
end
