module RepositoriesHelper

  def repository_tab_list
    ['overview', 'running-processes', 'file-statistics', 'red-flags', %w(combined-events-tab Events newspaper-o), 'accruals']
  end

  def load_repository_dashboard_file_stats
    fe_thread = Thread.new { @file_extension_hashes = load_file_extension_stats(@repository) }
    ct_thread = Thread.new { @content_type_hashes = load_content_type_stats(@repository) }
    fe_thread.join
    ct_thread.join
  end

  def load_repository_dashboard_events
    @events = @repository.cascaded_events.recent.cascadable.includes(eventable: :parent)
  end

end
