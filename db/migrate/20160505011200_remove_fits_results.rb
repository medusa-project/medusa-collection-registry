class RemoveFitsResults < ActiveRecord::Migration
  def change
    drop_table :fits_results
  end
end
