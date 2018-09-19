class AlterMessageSavingInAmqpAccrualDeleteJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :amqp_accrual_delete_jobs, :incoming_message, :text
    remove_column :amqp_accrual_delete_jobs, :cfs_file_uuid
  end
end
