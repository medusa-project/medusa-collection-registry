class CreatePronoms < ActiveRecord::Migration
  def change
    create_table :pronoms do |t|
      t.references :file_format, index: true, foreign_key: true
      t.string :pronom_id
      t.string :version

      t.timestamps null: false
    end
    remove_column :file_formats, :pronom_id
  end
end
