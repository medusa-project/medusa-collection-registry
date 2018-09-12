module RepositoriesHelper

  def repository_confirm_message
    Settings.classes.repositories_helper.confirm_message
  end

  def repository_tab_list
    ['overview', 'running-processes', 'file-statistics', 'red-flags', %w(combined-events-tab Events newspaper-o), 'amazon', 'accruals']
  end

  def load_repository_dashboard_file_stats
    fe_thread = Thread.new { @file_extension_hashes = load_file_extension_stats(@repository) }
    ct_thread = Thread.new { @content_type_hashes = load_content_type_stats(@repository) }
    fe_thread.join
    ct_thread.join
  end

  def load_repository_dashboard_events
    @events = @repository.cascaded_events.where('events.updated_at > ?', Time.now - 7.days).where(cascadable: true).includes(eventable: :parent)
  end

end
