# frozen_string_literal: true
require 'mime/types'

module CfsFilesHelper
  module_function

  def text_preview(cfs_file)
    candidate_string = raw_text_preview
    if candidate_string.encoding == Encoding::ASCII_8BIT
      candidate_string.force_encoding(Encoding::UTF_8)
    end
    unless candidate_string.encoding == Encoding::UTF_8
      candidate_string.encode('UTF-8', invalid: :replace, undef: :replace)
    end
    candidate_string
  rescue StandardError
    'error encoding text preview'
  end

  def raw_text_preview
    max_bytes = 2000
    bytes_to_get = min(cfs_file.size, max_bytes)
    preview = 'error getting text preview'

    case cfs_file.storage_root.root_type
    when :filesystem
      File.open(filepath) do |file|
        preview = file.read(bytes_to_get)
      end
    when :s3
      preview = cfs_file.storage_root.get_bytes(cfs_file.key, 0, bytes_to_get)
    else
      raise "Unrecognized storage root type #{cfs_file.storage_root.type}"
    end
    return preview

  rescue StandardError
    'error getting text preview'
  end

  def preview_view(cfs_file)
    viewer_type = if safe_can?(:download, cfs_file.file_group)
                    Preview::Resolver.instance.find_preview_viewer_type(cfs_file)
                  else
                    :default
                  end
    "preview_viewer_#{viewer_type}"
  end
end
