class AddHtmlCacheFields < ActiveRecord::Migration
  def up
    add_column :repositories, :notes_html, :text
    add_column :production_units, :notes_html, :text
    add_column :assessments, :notes_html, :text
    add_column :assessments, :preservation_risks_html, :text
    add_column :collections, :notes_html, :text
    add_column :collections, :description_html, :text
    add_column :collections, :private_description_html, :text
  end

  def down
    remove_column :repositories, :notes_html
    remove_column :production_units, :notes_html
    remove_column :assessments, :notes_html
    remove_column :assessments, :preservation_risks_html
    remove_column :collections, :notes_html
    remove_column :collections, :description_html
    remove_column :collections, :private_description_html
  end
end