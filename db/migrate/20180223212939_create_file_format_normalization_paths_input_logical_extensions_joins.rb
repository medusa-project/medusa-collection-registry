class CreateFileFormatNormalizationPathsInputLogicalExtensionsJoins < ActiveRecord::Migration[5.1]
  def change
    create_table :file_format_normalization_paths_input_logical_extensions_joins do |t|
      t.references :file_format_normalization_path, index: false
      t.references :logical_extension, index: false
      t.integer :position
      t.timestamps
    end
    add_index :file_format_normalization_paths_input_logical_extensions_joins, :file_format_normalization_path_id,
              name: 'ffnpilej_ffnp_id_idx'
    add_index :file_format_normalization_paths_input_logical_extensions_joins, :logical_extension_id,
              name: 'ffnpilej_le_id_idx'
  end
end
