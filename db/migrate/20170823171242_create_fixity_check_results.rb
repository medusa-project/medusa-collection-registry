class CreateFixityCheckResults < ActiveRecord::Migration[5.1]
  def change
    create_table :fixity_check_results do |t|
      t.references :cfs_file, foreign_key: true
      t.integer :status, null: false, index: true
      t.datetime :created_at, null: false, index: true
    end
  end
end
