class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.integer :repository_id
      t.string :title
      t.date :start_date
      t.date :end_date
      t.boolean :published
      t.boolean :ongoing
      t.text :description
      t.text :access_url
      t.text :file_package_summary
      t.text :rights_statement
      t.text :rights_restrictions
      t.text :notes

      t.timestamps
    end
  end
end
