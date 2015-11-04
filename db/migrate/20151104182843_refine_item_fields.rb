class RefineItemFields < ActiveRecord::Migration
  def change
    change_table :items do |t|
      t.string :local_title, default: ''
      t.string :local_description, default: ''
      t.string :batch, default: ''
      t.integer :file_count
      t.rename :photo_date, :reformatting_date
      t.string :reformatting_operator, default: ''
      t.string :record_series_id, default: ''
      t.string :archival_management_system_url, default: ''
      t.string :series, default: ''
      t.string :sub_series, default: ''
      t.string :box, default: ''
      t.string :folder, default: ''
      t.string :item_title, default: ''
      t.remove :book_name
    end
  end
end
