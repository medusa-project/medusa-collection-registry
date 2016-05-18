class ChangeItemDateToString < ActiveRecord::Migration
  def change
    change_column :items, :date, :string
  end
end
