#Note that this also creates the necessary join table to FileFormat
class CreateLogicalExtensions < ActiveRecord::Migration[5.1]
  def change

    create_table :logical_extensions do |t|
      t.string :extension, null: :false
      t.string :description, default: '', null: :false
    end
    add_index :logical_extensions, [:extension, :description], unique: true

    create_table :file_formats_logical_extensions_joins do |t|
      t.references :file_format, index: false
      t.references :logical_extension, index: false
      t.timestamps null: false
    end
    add_index :file_formats_logical_extensions_joins, :file_format_id, name: :fflej_file_format_id_idx
    add_index :file_formats_logical_extensions_joins, :logical_extension_id, name: :fflej_logical_extension_id_idx

    FileFormatProfilesFileExtensionsJoin.all.each do |join|
      file_extension = join.file_extension
      logical_extension = LogicalExtension.find_or_create_by(extension: file_extension.extension.strip, description: '')
      join.file_format_profile.file_formats.each do |file_format|
        FileFormatsLogicalExtensionsJoin.find_or_create_by(file_format: file_format, logical_extension: logical_extension)
      end
    end

  end
end

