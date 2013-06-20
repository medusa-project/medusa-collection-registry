class AddFieldsToRedFlags < ActiveRecord::Migration
  def change
    add_column :red_flags, :notes, :text
    add_column :red_flags, :priority, :string
    add_index :red_flags, :priority
    add_column :red_flags, :status, :string
    add_index :red_flags, :status
  end
end
