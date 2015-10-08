class CreateFileFormatTestReasons < ActiveRecord::Migration
  def change
    create_table :file_format_test_reasons do |t|
      t.string :label, unique: true, null: false
      t.timestamps
    end
  end
end
