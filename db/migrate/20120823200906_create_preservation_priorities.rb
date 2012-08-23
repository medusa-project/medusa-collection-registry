class CreatePreservationPriorities < ActiveRecord::Migration
  def change
    create_table :preservation_priorities do |t|
      t.string :name
      t.float :priority

      t.timestamps
    end
  end
end
