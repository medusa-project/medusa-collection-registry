module CfsFilesHelper

  module_function

  def text_preview(cfs_file)
    cfs_file.with_input_io do |io|
      io.readline(nil, 500)
    end
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
