class ChangeOutputFormatToAssociationOnFileFormatNormalizationPaths < ActiveRecord::Migration
  def change
    remove_column :file_format_normalization_paths, :output_format
    add_reference :file_format_normalization_paths, :output_format, index: true
  end
end
