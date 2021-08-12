class AddFieldsToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :requester_info, :text
    add_column :items, :ebook_status, :text
    add_column :items, :permalink, :text
    add_column :items, :reviewed_by, :text
  end
end
