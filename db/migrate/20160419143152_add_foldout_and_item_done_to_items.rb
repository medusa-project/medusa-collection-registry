class AddFoldoutAndItemDoneToItems < ActiveRecord::Migration
  def change
    add_column :items, :foldout_done, :boolean, null: false, default: false
    add_column :items, :item_done, :boolean, null: false, default: false
  end
end
