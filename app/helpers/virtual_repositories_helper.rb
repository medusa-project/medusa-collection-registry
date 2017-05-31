module VirtualRepositoriesHelper

  def virtual_repository_tab_list
    %w(overview file-statistics)
  end

  def load_virtual_repository_dashboard_file_stats
    fe_thread = Thread.new { @file_extension_hashes = load_virtual_repository_file_extension_stats(@virtual_repository) }
    ct_thread = Thread.new { @content_type_hashes = load_virtual_repository_content_type_stats(@virtual_repository) }
    fe_thread.join
    ct_thread.join
  end

end