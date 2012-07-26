class AddLastAccessDateToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :last_access_date, :date
  end
end
