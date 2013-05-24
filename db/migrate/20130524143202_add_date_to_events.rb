class AddDateToEvents < ActiveRecord::Migration
  def up
    add_column :events, :date, :date
    Event.all.each do |event|
      event.update_column(:date, event.created_at.to_date)
    end
  end

  def down
    remove_column :events, :date
  end
end
