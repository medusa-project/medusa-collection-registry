class RemoveUserIdFromEvents < ActiveRecord::Migration
  def up
    add_column :events, :actor_netid, :string
    add_index :events, :actor_netid
    Event.all.each do |event|
      user = User.find(event.user_id)
      event.update_column(:actor_netid, user.uid)
    end
    remove_column :events, :user_id
  end

  def down
    add_column :events, :user_id, :integer
    add_index :events, :user_id
    Event.all.each do |event|
      user = User.find_by_uid(event.actor_netid)
      event.update_column(:user_id, user.id) if user
    end
    remove_column :events, :actor_netid
  end
end
