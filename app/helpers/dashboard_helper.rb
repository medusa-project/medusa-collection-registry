module DashboardHelper
  include ActionView::Helpers::NumberHelper
  def dashboard_tab_list
    ['storage-overview', 'running-processes', 'file-statistics', 'red-flags']
  end

  # File Stats for bit preservation

  def list_of_bit_file_formats
    # return list of unique content types
    BitFile.where(:dx_ingested => true).order('content_type').select('content_type').uniq.collect(&:content_type)
  end

  def size_bits_type_format (ct)
    # only active records of certain format that have been ingested
    number_with_precision(BitFile.where(:content_type => ct).where(:dx_ingested => true).sum(:size)/1000000.0, :precision => 4)
  end

  def file_count_bits_type_format (ct)
    # only active records of certain format that have been ingested
    BitFile.where(:content_type => ct).where(:dx_ingested => true).count
  end

  def size_bits_total
    # only active records that have been ingested
    number_with_precision(BitFile.where(:dx_ingested => true).sum(:size) / 1000000.0, :precision => 4)
  end

  def file_count_bits_total
    # only active records that have been ingested
    BitFile.where(:dx_ingested => true).count
  end


  # File stats for objects preservation

  def list_of_object_file_formats
    # return list of unique content types
    return []
  end

  def size_objects_type_format (ct)
     # only active records of certain format that have been ingested
     return number_with_precision(0.0, :precision => 4)
  end

  def file_count_objects_type_format (ct)
     # only active records of certain format that have been ingested
     return 0
  end

  def size_objects_total
    # only active records that have been ingested
    return number_with_precision(0.0, :precision => 4)
  end

  def file_count_objects_total
    # only active records that have been ingested
    return 0
  end




































  def z_total_size
    # BitFile.collections.collect {|c| c.total_size}.sum
  end
end