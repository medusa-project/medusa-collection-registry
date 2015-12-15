class AddFileNameToJobItemBulkImport < ActiveRecord::Migration
  def change
    add_column :job_item_bulk_imports, :file_name, :string
  end
end
