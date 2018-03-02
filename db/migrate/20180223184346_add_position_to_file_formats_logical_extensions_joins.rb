class AddPositionToFileFormatsLogicalExtensionsJoins < ActiveRecord::Migration[5.1]
  def change
    add_column :file_formats_logical_extensions_joins, :position, :integer
  end
end
