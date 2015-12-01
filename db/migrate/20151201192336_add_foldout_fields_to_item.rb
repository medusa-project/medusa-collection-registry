class AddFoldoutFieldsToItem < ActiveRecord::Migration
  def change
    add_column :items, :foldout_present, :boolean, null: false, default: false
    add_column :items, :foldout_done, :boolean, null: false, default: false
    add_column :items, :equipment, :string, default: ''
  end
end
