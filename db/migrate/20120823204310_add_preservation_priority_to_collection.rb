class AddPreservationPriorityToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :preservation_priority_id, :integer
  end

end
