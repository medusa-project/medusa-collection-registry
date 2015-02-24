class CreateStaticPages < ActiveRecord::Migration
  def change
    create_table :static_pages do |t|
      t.string :key, unique: true
      t.text :page_text, default: ''

      t.timestamps null: false
    end
  end
end
