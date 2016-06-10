class CreateAmqpAccrualIngestJobs < ActiveRecord::Migration
  def change
    create_table :amqp_accrual_ingest_jobs do |t|
      t.string :client, null: false
      t.string :staging_path, null: false
      t.string :uuid
      t.timestamps null: false
    end
    add_index :amqp_accrual_ingest_jobs, [:client, :staging_path], unique: true, name: :amqp_accrual_ingest_jobs_unique_client_and_path
  end
end
