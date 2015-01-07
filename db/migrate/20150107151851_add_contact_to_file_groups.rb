class AddContactToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :contact_id, :integer, index: true
  end
end
