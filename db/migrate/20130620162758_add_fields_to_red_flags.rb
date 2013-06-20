class AddFieldsToRedFlags < ActiveRecord::Migration
  def up
    add_column :red_flags, :notes, :text
    add_column :red_flags, :priority, :string
    add_index :red_flags, :priority
    add_column :red_flags, :status, :string
    add_index :red_flags, :status
    RedFlag.update_all :priority => 'medium', :status => 'flagged'
  end

  def down
    remove_column :red_flags, :status
    remove_column :red_flags, :priority
    remove_column :red_flags, :notes
  end
end
