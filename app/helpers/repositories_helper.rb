module RepositoriesHelper

  def repository_confirm_message
    'This is irreversible. Associated collections and their associated assessments and file groups will also be deleted.'
  end

  def repository_tab_list
    ['overview', 'running-processes', 'file-statistics', 'red-flags', ['combined-events-tab', 'Events', 'newspaper-o'], 'amazon', 'accruals']
  end

  #In non-test environments speed this up using threads; in test environment this may be problematic because of how we manage db connections
  #for javascript tests
  if Rails.env.test?
    def load_repository_dashboard_file_stats
      @file_extension_hashes = ActiveRecord::Base.connection.
          select_all('SELECT file_extension_id, extension, file_size, file_count FROM view_file_extension_stats_by_repository WHERE repository_id = $1', nil, [[nil, @repository.id]]).to_hash
      @content_type_hashes = ActiveRecord::Base.connection.
          select_all('SELECT content_type_id, name, file_size, file_count FROM view_file_content_type_stats_by_repository WHERE repository_id = $1', nil, [[nil, @repository.id]])
      @bit_level_storage_summary = ActiveRecord::Base.connection.
          select_all('SELECT COALESCE(SUM(COALESCE(F.size,0)), 0) AS size, COUNT(*) AS count FROM view_cfs_files_to_parents V JOIN cfs_files F ON V.cfs_file_id = F.id WHERE V.repository_id = $1', nil, [[nil, @repository.id]]).to_hash.first
    end
  else
    def load_repository_dashboard_file_stats
      fe_thread = Thread.new { @file_extension_hashes = ActiveRecord::Base.connection.
          select_all('SELECT file_extension_id, extension, file_size, file_count FROM view_file_extension_stats_by_repository WHERE repository_id = $1', nil, [[nil, @repository.id]]).to_hash }
      ct_thread = Thread.new { @content_type_hashes = ActiveRecord::Base.connection.
          select_all('SELECT content_type_id, name, file_size, file_count FROM view_file_content_type_stats_by_repository WHERE repository_id = $1', nil, [[nil, @repository.id]]) }
      blss_thread = Thread.new { @bit_level_storage_summary = ActiveRecord::Base.connection.
          select_all('SELECT COALESCE(SUM(COALESCE(F.size,0)), 0) AS size, COUNT(*) AS count FROM view_cfs_files_to_parents V JOIN cfs_files F ON V.cfs_file_id = F.id WHERE V.repository_id = $1', nil, [[nil, @repository.id]]).to_hash.first }
      fe_thread.join
      ct_thread.join
      blss_thread.join
    end
  end

  def load_repository_dashboard_events
    @events = @repository.cascaded_events.where('events.updated_at > ?', Time.now - 7.days).where(cascadable: true).includes(eventable: :parent)
  end

end
