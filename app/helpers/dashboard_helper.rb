module DashboardHelper
  include ActionView::Helpers::NumberHelper
  def dashboard_tab_list
    ['storage-overview', 'running-processes', 'file-statistics', 'red-flags', ['combined-events-tab', 'Events']]
  end

  # File Stats for bit preservation

  #According to the Rails docs this should be possible by
  #CfsFileInfo.distinct.pluck(:content_type), but I couldn't get that working.
  #Perhaps it's Rails4? Regardless that would be better because it'd be a lot
  #more efficient - if that turns into a problem research some more, or even
  #just use SQL directly for this.
  def list_of_bit_file_formats
    # return list of unique content types
    CfsFileInfo.pluck(:content_type).uniq
  end

  def size_bits_type_format (ct)
    # only active records of certain format that have been ingested
    number_with_precision(CfsFileInfo.where(:content_type => ct).sum(:size)/1000000.0, :precision => 4)
  end

  def file_count_bits_type_format (ct)
    # only active records of certain format that have been ingested
    CfsFileInfo.where(:content_type => ct).count
  end

  def size_bits_total
    # only active records that have been ingested
    number_with_precision(CfsFileInfo.sum(:size) / 1000000.0, :precision => 4)
  end

  def file_count_bits_total
    # only active records that have been ingested
    CfsFileInfo.count
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

end