class RemovePreservationPriorities < ActiveRecord::Migration[5.1]
  def change
    drop_table :preservation_priorities
    remove_column :collections, :preservation_priority_id
  end
end
