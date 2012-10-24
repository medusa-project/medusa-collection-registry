class RemoveFieldsFromFileGroups < ActiveRecord::Migration
  def up
    remove_column :file_groups, :file_types
    remove_column :file_groups, :file_types_html
    remove_column :file_groups, :origin
    remove_column :file_groups, :origin_html
    remove_column :file_groups, :misc_notes
    remove_column :file_groups, :misc_notes_html
    rename_column :file_groups, :file_hierarchy, :directory_structure
    rename_column :file_groups, :file_hierarchy_html, :directory_structure_html
  end

  def down
    add_column :file_groups, :file_types, :text
    add_column :file_groups, :file_types_html, :text
    add_column :file_groups, :origin, :text
    add_column :file_groups, :origin_html, :text
    add_column :file_groups, :misc_notes, :text
    add_column :file_groups, :misc_notes_html, :text
    rename_column :file_groups, :directory_structure, :file_hierarchy
    rename_column :file_groups, :directory_structure_html, :file_hierarchy_html
  end
end
