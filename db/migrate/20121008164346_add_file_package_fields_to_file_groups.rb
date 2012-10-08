class AddFilePackageFieldsToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :naming_conventions, :text
    add_column :file_groups, :naming_conventions_html, :text
    add_column :file_groups, :file_hierarchy, :text
    add_column :file_groups, :file_hierarchy_html, :text
    add_column :file_groups, :file_types, :text
    add_column :file_groups, :file_types_html, :text
    add_column :file_groups, :origin, :text
    add_column :file_groups, :origin_html, :text
    add_column :file_groups, :misc_notes, :text
    add_column :file_groups, :misc_notes_html, :text
  end
end
