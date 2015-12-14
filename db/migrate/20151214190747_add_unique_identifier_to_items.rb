class AddUniqueIdentifierToItems < ActiveRecord::Migration
  def change
    add_column :items, :unique_identifier, :string
  end
end
