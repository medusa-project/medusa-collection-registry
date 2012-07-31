class AddContactIdToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :contact_id, :integer
    add_index :repositories, :contact_id
  end
end
