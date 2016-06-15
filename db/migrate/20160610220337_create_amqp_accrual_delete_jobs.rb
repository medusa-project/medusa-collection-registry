class CreateAmqpAccrualDeleteJobs < ActiveRecord::Migration
  def change
    create_table :amqp_accrual_delete_jobs do |t|
      t.string :cfs_file_uuid, null: false
      t.string :client, null: false
      t.timestamps null: false
    end
    add_index :amqp_accrual_delete_jobs, :cfs_file_uuid
    add_index :amqp_accrual_delete_jobs, :client
  end
end
