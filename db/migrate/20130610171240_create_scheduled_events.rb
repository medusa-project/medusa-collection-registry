class CreateScheduledEvents < ActiveRecord::Migration
  def change
    create_table :scheduled_events do |t|
      t.string :key
      t.string :state
      t.date :action_date
      t.string :actor_netid
      t.integer :scheduled_eventable_id
      t.string :scheduled_eventable_type
      t.text :note

      t.timestamps
    end
    add_index :scheduled_events, :key
    add_index :scheduled_events, :actor_netid
    add_index :scheduled_events, :scheduled_eventable_id
    add_index :scheduled_events, :scheduled_eventable_type
  end
end
