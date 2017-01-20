class CreateWorkflowItemIngestRequests < ActiveRecord::Migration
  def change
    create_table :workflow_item_ingest_requests do |t|
      t.references :workflow_project_item_ingest, index: false, foreign_key: true
      t.references :item, index: false, foreign_key: true

      t.timestamps null: false
    end
    add_index :workflow_item_ingest_requests, :workflow_project_item_ingest_id, name: 'workflow_item_ingest_requests_pii_index'
    add_index :workflow_item_ingest_requests, :item_id, unique: true, name: 'workflow_item_ingest_requests_item_index'
  end
end
