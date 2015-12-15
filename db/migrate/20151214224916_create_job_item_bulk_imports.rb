class CreateJobItemBulkImports < ActiveRecord::Migration
  def change
    create_table :job_item_bulk_imports do |t|
      t.references :user, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
