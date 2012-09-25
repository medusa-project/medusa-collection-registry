class AddActiveDatesToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :active_start_date, :date
    add_column :repositories, :active_end_date, :date
  end
end
