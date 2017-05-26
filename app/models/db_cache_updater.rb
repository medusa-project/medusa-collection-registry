#see also the sql under db/views_and_functions
module DbCacheUpdater

  module_function

  def update_content_type_cache
    ActiveRecord::Base.connection.execute("SELECT update_cache_content_type_stats_by_collection()")
  end

  def update_file_extension_cache
    ActiveRecord::Base.connection.execute("SELECT update_cache_file_extension_stats_by_collection()")
  end

end