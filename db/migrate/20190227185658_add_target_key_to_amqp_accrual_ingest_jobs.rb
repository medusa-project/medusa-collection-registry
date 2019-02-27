class AddTargetKeyToAmqpAccrualIngestJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :amqp_accrual_ingest_jobs, :target_key, :string
    add_index :amqp_accrual_ingest_jobs, [:client, :target_key], unique: true
  end
end
