module CfsFilesHelper

  def text_preview(cfs_file)
    cfs_file.with_input_io do |io|
      io.readline(nil, 500)
    end
  end

  def cfs_file_download_link(cfs_file)
    download_cfs_file_path(cfs_file)
  end

  def cfs_file_view_link(cfs_file)
    view_cfs_file_path(cfs_file)
  end

end
