class RemovePidColumnFromBookTrackerTasks < ActiveRecord::Migration
  def change
    remove_column :book_tracker_tasks, :pid
  end
end
