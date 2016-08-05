class CreateFileFormatNormalizationPaths < ActiveRecord::Migration
  def change
    create_table :file_format_normalization_paths do |t|
      t.references :file_format, index: true, foreign_key: true
      t.string :name
      t.string :output_format
      t.string :software
      t.string :software_version
      t.string :operating_system
      t.text :software_settings
      t.text :potential_for_loss

      t.timestamps null: false
    end
  end
end
