class AddNotesToFileFormatNormalizationPaths < ActiveRecord::Migration
  def change
    add_column :file_format_normalization_paths, :notes, :text
  end
end
