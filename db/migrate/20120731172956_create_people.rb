class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :net_id

      t.timestamps
    end
    add_index :people, :net_id
  end
end
