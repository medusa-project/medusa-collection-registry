module DashboardHelper
  include ActionView::Helpers::NumberHelper

  def dashboard_tab_list
    tabs = ['storage-overview', 'running-processes', 'file-statistics', 'red-flags', %w(combined-events-tab Events newspaper-o), 'amazon', 'accruals']
    tabs << 'file-group-deletions' if current_user and current_user.superuser?
    tabs
  end

  # File stats for objects preservation

  def list_of_object_file_formats
    # return list of unique content types
    []
  end

  def size_objects_type_format (ct)
    # only active records of certain format that have been ingested
    number_with_precision(0.0, precision: 4)
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

  INGEST_STATE_LABELS = {start: 'Starting', copying: 'Copying from staging', amazon_backup: 'Backing up to Amazon',
                         end: 'Ended'}

  def ingest_state_text(state)
    INGEST_STATE_LABELS[state.to_sym] || 'Unknown'
  end

  def accrual_conflict_indicator_class(workflow_accrual_job)
    if workflow_accrual_job.has_serious_conflicts?
      "accrual-job-conflict-indicator"
    else
      ""
    end
  end

end