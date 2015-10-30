class ChangeSpecialNotesToNotesOnItems < ActiveRecord::Migration
  def change
    rename_column :items, :special_notes, :notes
  end
end
