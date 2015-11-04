class ChangeItemLocalDescriptionToText < ActiveRecord::Migration
  def change
    change_column :items, :local_description, :text, default: ''
  end
end
