class DropScheduledEvents < ActiveRecord::Migration
  def change
    drop_table :scheduled_events
  end
end
