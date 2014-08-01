class RenamePersonNetIdToEmail < ActiveRecord::Migration
  def change
    rename_column :people, :net_id, :email
    rename_column :events, :actor_netid, :actor_email
    rename_column :scheduled_events, :actor_netid, :actor_email
  end
end
