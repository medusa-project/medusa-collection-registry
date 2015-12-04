class RemoveFoldoutDoneFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :foldout_done
  end
end
