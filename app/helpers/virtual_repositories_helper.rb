module VirtualRepositoriesHelper

  def virtual_repository_tab_list
    %w(overview file-statistics)
  end

  def load_virtual_repository_dashboard_file_stats
    fe_thread = Thread.new { @file_extension_hashes = load_virtual_repository_file_extension_stats(@virtual_repository) }
    ct_thread = Thread.new { @content_type_hashes = load_virtual_repository_content_type_stats(@virtual_repository) }
    ids_string = "(#{@virtual_repository.collection_ids.join(',')})"
    blss_thread = Thread.new { @bit_level_storage_summary = ActiveRecord::Base.connection.
        select_all("SELECT COALESCE(SUM(COALESCE(F.size,0)), 0) AS size, COUNT(*) AS count FROM view_cfs_files_to_parents V JOIN cfs_files F ON V.cfs_file_id = F.id WHERE V.collection_id IN #{ids_string}").to_hash.first }
    fe_thread.join
    ct_thread.join
    blss_thread.join
  end

end