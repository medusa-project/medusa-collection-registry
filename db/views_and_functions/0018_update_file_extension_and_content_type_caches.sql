CREATE OR REPLACE FUNCTION update_cache_file_extension_stats_by_collection()
  RETURNS void
  LANGUAGE SQL
  AS $$
    DELETE FROM cache_file_extension_stats_by_collection;
    INSERT INTO cache_file_extension_stats_by_collection (collection_id, file_extension_id, extension, file_count, file_size)
      (SELECT collection_id, file_extension_id, extension, file_count, file_size FROM view_file_extension_stats_by_collection);
$$;

CREATE OR REPLACE FUNCTION update_cache_content_type_stats_by_collection()
  RETURNS void
  LANGUAGE SQL
  AS $$
    DELETE FROM cache_content_type_stats_by_collection;
    INSERT INTO cache_content_type_stats_by_collection (collection_id, content_type_id, name, file_count, file_size)
      (SELECT collection_id, content_type_id, name, file_count, file_size FROM view_file_content_type_stats_by_collection);
$$;