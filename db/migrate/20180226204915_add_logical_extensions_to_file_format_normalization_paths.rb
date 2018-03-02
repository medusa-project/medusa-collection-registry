#We've decided to make the joins from (input/output) logical extensions to file format
# normalization paths one to many instead of many to many. So we can get rid of the join
# model and simply store the logical extension ids on the file format normalization path
# model itself.
class AddLogicalExtensionsToFileFormatNormalizationPaths < ActiveRecord::Migration[5.1]
  def change
    add_column :file_format_normalization_paths, :input_logical_extension_id, :integer
    add_column :file_format_normalization_paths, :output_logical_extension_id, :integer

    drop_table :file_format_normalization_paths_input_logical_extensions_joins
    drop_table :file_format_normalization_paths_output_logical_extensions_joins
  end
end
