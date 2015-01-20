class CreateCascadedEventJoins < ActiveRecord::Migration
  def change
    create_table :cascaded_event_joins do |t|
      t.references :cascaded_eventable, polymorphic: true
      t.references :event, index: true
      t.timestamps null: false
    end
    add_foreign_key :cascaded_event_joins, :events
    add_index :cascaded_event_joins, [:cascaded_eventable_type, :cascaded_eventable_id, :event_id], unique: true, name: :unique_cascaded_events
    if Event.respond_to?(:rebuild_cascaded_event_cache)
      Event.rebuild_cascaded_event_cache
    end
  end
end
