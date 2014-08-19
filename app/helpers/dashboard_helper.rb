module DashboardHelper
  include ActionView::Helpers::NumberHelper

  def dashboard_tab_list
    ['storage-overview', 'running-processes', 'file-statistics', 'red-flags', ['combined-events-tab', 'Events'], 'amazon']
  end

  # File Stats for bit preservation
  #return a hash with content_type => hash(total_size, count)
  def bit_file_info_summary
    Hash.new.tap do |h|
      CfsFile.select('content_type, sum(size) as total_size, count(*) as count').group('content_type').order('content_type').each do |record|
        content_type = record[:content_type] || 'Unknown'
        h[content_type] = {:size => record[:total_size] || 0, :count => record[:count] || 0}
      end
    end
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