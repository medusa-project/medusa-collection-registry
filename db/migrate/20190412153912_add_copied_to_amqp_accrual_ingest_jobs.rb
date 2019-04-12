class AddCopiedToAmqpAccrualIngestJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :amqp_accrual_ingest_jobs, :copied, :boolean, default: false
  end
end
