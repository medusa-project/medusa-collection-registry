class AddStatusToItems < ActiveRecord::Migration
  def change
    add_column :items, :status, :string
    add_index :items, :status
  end
end
