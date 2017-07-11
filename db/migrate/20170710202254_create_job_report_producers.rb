class CreateJobReportProducers < ActiveRecord::Migration[5.1]
  def change
    create_table :job_report_producers do |t|
      t.references :user, foreign_key: true
      t.references :producer, foreign_key: true

      t.timestamps
    end
  end
end
