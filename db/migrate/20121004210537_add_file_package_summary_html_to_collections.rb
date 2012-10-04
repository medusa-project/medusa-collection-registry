class AddFilePackageSummaryHtmlToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :file_package_summary_html, :text
  end
end
