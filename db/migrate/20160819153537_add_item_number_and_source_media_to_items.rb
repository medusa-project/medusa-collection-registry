class AddItemNumberAndSourceMediaToItems < ActiveRecord::Migration
  def change
    add_column :items, :item_number, :string
    add_column :items, :source_media, :string
  end
end
