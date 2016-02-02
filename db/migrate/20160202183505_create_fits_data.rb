class CreateFitsData < ActiveRecord::Migration
  def change
    create_table :fits_data do |t|
      t.string :file_format, default: ''
      t.string :file_format_version, default: ''
      t.string :mime_type, default: ''
      t.string :pronom_id, default: ''
      t.decimal :file_size
      t.datetime :last_modified_date
      t.datetime :creation_date
      t.string :creating_application, default: ''
      t.string :well_formed, default: ''
      t.string :is_valid, default: ''
      t.string :message, default: ''
      t.integer :audio_bit_depth
      t.string :audio_byte_order, default: ''
      t.string :audio_data_encoding, default: ''
      t.integer :audio_sample_rate
      t.string :document_protection, default: ''
      t.string :document_rights_management, default: ''
      t.integer :image_bits_per_sample
      t.string :image_byte_order, default: ''
      t.string :image_color_space, default: ''
      t.string :image_compression_scheme, default: ''
      t.string :text_character_set, default: ''
      t.string :text_markup_basis, default: ''
      t.string :text_markup_basis_version, default: ''
      t.integer :video_bit_depth
      t.string :video_compression_scheme, default: ''
      t.integer :video_sample_rate
    end
  end
end
