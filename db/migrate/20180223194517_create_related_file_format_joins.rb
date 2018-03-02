class CreateRelatedFileFormatJoins < ActiveRecord::Migration[5.1]
  def change
    create_table :related_file_format_joins do |t|
      t.references :file_format, index: true
      t.references :related_file_format, index: true

      t.timestamps null: false
    end
  end
end
