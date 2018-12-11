module CfsFilesHelper

  module_function

  def text_preview(cfs_file)
    cfs_file.with_input_io do |io|
      io.readline(nil, 500)
    end
  end

  #In this and cfs_file_view_link if possible we give a direct link to the content,
  # otherwise we direct through a controller action to get it. The difference in our
  # case is storage in S3 versus storage on the filesystem
  def cfs_file_download_link(cfs_file)
    case cfs_file.storage_root.root_type
    when :filesystem
      download_cfs_file_path(cfs_file)
    when :s3
      cfs_file.storage_root.presigned_get_url(cfs_file.key, response_content_disposition: disposition('attachment', cfs_file),
                                              response_content_type: safe_content_type(cfs_file))
    else
      raise "Unrecognized storage root type #{cfs_file.storage_root.type}"
    end
  end

  def cfs_file_view_link(cfs_file)
    case cfs_file.storage_root.root_type
    when :filesystem
      view_cfs_file_path(cfs_file)
    when :s3
      cfs_file.storage_root.presigned_get_url(cfs_file.key, response_content_disposition: disposition('inline', cfs_file),
                                              response_content_type: safe_content_type(cfs_file))
    else
      raise "Unrecognized storage root type #{cfs_file.storage_root.type}"
    end
  end

  def cfs_file_content_preview_link(cfs_file)
    case cfs_file.storage_root.root_type
    when :filesystem
      preview_content_cfs_file_path(cfs_file)
    when :s3
      cfs_file.storage_root.presigned_get_url(cfs_file.key, response_content_disposition: disposition('inline', cfs_file),
                                              response_content_type: safe_content_type(cfs_file))
    else
      raise "Unrecognized storage root type #{cfs_file.storage_root.type}"
    end
  end

  def disposition(type, cfs_file)
    if browser.chrome? or browser.safari?
      %Q(#{type}; filename="#{cfs_file.name}"; filename*=utf-8"#{URI.encode(cfs_file.name)}")
    elsif browser.firefox?
      %Q(#{type}; filename="#{cfs_file.name}")
    else
      %Q(#{type}; filename="#{cfs_file.name}"; filename*=utf-8"#{URI.encode(cfs_file.name)}")
    end
  end

  def safe_content_type(cfs_file)
    cfs_file.content_type_name || 'application/octet-stream'
  end

end
