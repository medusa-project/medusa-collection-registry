module DashboardHelper
  include ActionView::Helpers::NumberHelper

  def dashboard_tab_list
    tabs = ['storage-overview', 'running-processes', 'file-statistics', 'red-flags', %w(combined-events-tab Events newspaper-o), 'accruals']
    tabs << 'file-group-deletions' if current_user and current_user.superuser?
    tabs
  end

  def ingest_state_text(state)
    t(state, scope: 'dashboard.ingest_state_labels', default: t('dashboard.ingest_state_labels.unknown'))
  end

  def accrual_conflict_indicator_class(workflow_accrual_job)
    if workflow_accrual_job.has_serious_conflicts?
      "accrual-job-conflict-indicator"
    else
      ""
    end
  end

end