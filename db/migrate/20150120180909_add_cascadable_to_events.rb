class AddCascadableToEvents < ActiveRecord::Migration
  def change
    add_column :events, :cascadable, :boolean, default: true
    Event.update_all(cascadable: true)
    add_index :events, :cascadable
  end
end
