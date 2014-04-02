module DashboardHelper
  include ActionView::Helpers::NumberHelper
  def dashboard_tab_list
    ['storage-overview', 'running-processes', 'file-statistics', 'red-flags', ['combined-events-tab', 'Events']]
  end

  # File Stats for bit preservation

  #According to the Rails docs this should be possible by
  #CfsFile.distinct.pluck(:content_type), but I couldn't get that working.
  #Perhaps it's Rails4? Regardless that would be better because it'd be a lot
  #more efficient - if that turns into a problem research some more, or even
  #just use SQL directly for this.
  def list_of_bit_file_formats
    # return list of unique content types
    CfsFile.where('content_type IS NOT NULL').pluck(:content_type).uniq.sort
  end

  def size_bits_type_format (content_type)
    # only active records of certain format that have been ingested
    CfsFile.where(:content_type => content_type).sum(:size)
  end

  def file_count_bits_type_format (content_type)
    # only active records of certain format that have been ingested
    CfsFile.where(:content_type => content_type).count
  end

  def size_bits_total
    CfsFile.sum(:size)
  end

  def file_count_bits_total
    # only active records that have been ingested
    CfsFile.count
  end

  # File stats for objects preservation

  def list_of_object_file_formats
    # return list of unique content types
    []
  end

  def size_objects_type_format (ct)
     # only active records of certain format that have been ingested
     number_with_precision(0.0, :precision => 4)
  end

  def file_count_objects_type_format (ct)
     # only active records of certain format that have been ingested
     0
  end

  def size_objects_total
    # only active records that have been ingested
    0
  end

  def file_count_objects_total
    # only active records that have been ingested
    0
  end

end