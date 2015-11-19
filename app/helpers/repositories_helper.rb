module RepositoriesHelper

  def repository_confirm_message
    'This is irreversible. Associated collections and their associated assessments and file groups will also be deleted.'
  end

  def repository_tab_list
    ['overview', 'running-processes', 'file-statistics', 'red-flags', ['combined-events-tab', 'Events', 'newspaper-o'], 'amazon', 'accruals']
  end

  def load_repository_dashboard_file_stats
    fe_thread = Thread.new { @file_extension_hashes = ActiveRecord::Base.connection.
        select_all(load_repository_dashboard_file_extension_sql, nil, [[nil, @repository.id]]).to_hash }
    ct_thread = Thread.new { @content_type_hashes = ActiveRecord::Base.connection.
        select_all(load_repository_dashboard_content_type_sql, nil, [[nil, @repository.id]]) }
    blss_thread = Thread.new { @bit_level_storage_summary = ActiveRecord::Base.connection.
        select_all('SELECT COALESCE(SUM(COALESCE(F.size,0)), 0) AS size, COUNT(*) AS count FROM view_cfs_files_to_parents V JOIN cfs_files F ON V.cfs_file_id = F.id WHERE V.repository_id = $1', nil, [[nil, @repository.id]]).to_hash.first }
    fe_thread.join
    ct_thread.join
    blss_thread.join
  end

  def load_repository_dashboard_content_type_sql
    <<SQL
    SELECT CTS.content_type_id, CTS.name, CTS.file_size, CTS.file_count,
    COALESCE(CTC.count,0) AS tested_count
    FROM view_file_content_type_stats_by_repository CTS
    LEFT JOIN (SELECT content_type_id, count FROM view_tested_file_content_type_counts WHERE repository_id = $1) CTC
    ON CTS.content_type_id = CTC.content_type_id
    WHERE repository_id = $1
SQL
  end

  def load_repository_dashboard_file_extension_sql
    <<SQL
    SELECT FES.file_extension_id, FES.extension, FES.file_size, FES.file_count,
    COALESCE(FEC.count,0) AS tested_count
    FROM view_file_extension_stats_by_repository FES
    LEFT JOIN (SELECT file_extension_id, count FROM view_tested_file_file_extension_counts WHERE repository_id = $1) FEC
    ON FES.file_extension_id = FEC.file_extension_id
    WHERE repository_id = $1
SQL
  end

  def load_repository_dashboard_events
    @events = @repository.cascaded_events.where('events.updated_at > ?', Time.now - 7.days).where(cascadable: true).includes(eventable: :parent)
  end

end
