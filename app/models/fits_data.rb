class FitsData < ActiveRecord::Base
  include FitsDatetimeParser

  belongs_to :cfs_file

  SIMPLE_STRING_FIELDS = {
      file_format: 'fits/identification/identity/@format',
      file_format_version: 'fits/identification/identity/version',
      mime_type: 'fits/identification/identity/@mimetype',
      pronom_id: 'fits/identification/identity/externalIdentifier[@type="puid"]',
      file_size: 'fits/fileinfo/size',
      creating_application: 'fits/fileinfo/creatingApplicationName',
      well_formed: 'fits/filestatus/well-formed',
      is_valid: 'fits/filestatus/valid',
      message: 'fits/filestatus/message',
      audio_bit_depth: 'fits/metadata/audio/bitDepth',
      audio_byte_order: 'fits/metadata/audio/byteOrder',
      audio_data_encoding: 'fits/metadata/audio/audioDataEncoding',
      audio_sample_rate: 'fits/metadata/audio/sampleRate',
      document_protection: 'fits/metadata/document/isProtected',
      document_rights_management: 'fits/metadata/document/isRightsManaged',
      image_bits_per_sample: 'fits/metadata/image/bitsPerSample',
      image_byte_order: 'fits/metadata/image/byteOrder',
      image_color_space: 'fits/metadata/image/colorSpace',
      image_compression_scheme: 'fits/metadata/image/compressionScheme',
      text_character_set: 'fits/metadata/text/charset',
      text_markup_basis: 'fits/metadata/text/markupBasis',
      text_markup_basis_version: 'fits/metadata/text/markupBasisVersion',
      video_bit_depth: 'fits/metadata/video/bitDepth',
      video_compressor: 'fits/metadata/video/videoCompressor',
      video_compression_scheme: 'fits/metadata/video/compressionScheme',
      video_sample_rate: 'fits/metadata/video/sampleRate'
  }

  DATE_FIELDS = {
      last_modified_date: 'fits/fileinfo/lastmodified',
      creation_date: 'fits/created'
  }

  def update_from(xml)
    doc = Nokogiri::XML.parse(xml).remove_namespaces!
    update_simple_string_fields(doc)
    update_date_fields(doc)
  end

  def update_simple_string_fields(doc)
    SIMPLE_STRING_FIELDS.each do |field, xpath|
      node = doc.at_xpath(xpath)
      value = node.present? ? node.text : nil
      send("#{field}=", value)
    end
  end

  def update_date_fields(doc)
    DATE_FIELDS.each do |field, xpath|
      node = doc.at_xpath(xpath)
      value = node.present? ? safe_parse_datetime(node.text, node['toolname']) : nil
      send("#{field}=", value)
    end
  end


end