class RemoveFilePackageSummaryFromCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :file_package_summary
    remove_column :collections, :file_package_summary_html
  end
end
