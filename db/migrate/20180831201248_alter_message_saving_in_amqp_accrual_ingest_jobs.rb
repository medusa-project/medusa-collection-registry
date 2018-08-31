class AlterMessageSavingInAmqpAccrualIngestJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :amqp_accrual_ingest_jobs, :incoming_message, :text
    remove_column :amqp_accrual_ingest_jobs, :staging_path
  end
end
