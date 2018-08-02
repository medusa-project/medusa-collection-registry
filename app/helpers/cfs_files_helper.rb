module CfsFilesHelper

  def galleria_data_hashes(directory)
    image_files = directory.cfs_files.order('cfs_files.name asc').includes(:content_type, :file_extension).select { |f| f.preview_type_is_image? }
    image_files.collect do |f|
      {image: galleria_cfs_file_path(f), thumb: thumbnail_cfs_file_path(f), link: cfs_file_path(f),
       title: f.name}
    end
  end

  def text_preview(cfs_file)
    cfs_file.with_input_io do |io|
      io.readline(nil, 500)
    end
  end

end
