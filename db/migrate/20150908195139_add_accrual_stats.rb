class AddAccrualStats < ActiveRecord::Migration
  def change
    change_table :workflow_accrual_files do |t|
      t.decimal :size, default: 0
    end
    change_table :workflow_accrual_directories do |t|
      t.decimal :size, default: 0
      t.integer :count, default: 0
    end
  end
end
