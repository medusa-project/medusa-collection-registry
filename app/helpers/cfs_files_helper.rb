module CfsFilesHelper

  module_function

  def text_preview(cfs_file)
    cfs_file.with_input_io do |io|
      io.readline(nil, 500)
    end
  end


end
