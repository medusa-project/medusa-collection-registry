class RemoveIngestStatuses < ActiveRecord::Migration
  def up
    drop_table :ingest_statuses
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
