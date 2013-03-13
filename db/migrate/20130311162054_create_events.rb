class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :key
      t.text :note
      t.references :eventable, :polymorphic => true
      t.references :user

      t.timestamps
    end
    add_index :events, :user_id
    add_index :events, :eventable_id
  end
end
