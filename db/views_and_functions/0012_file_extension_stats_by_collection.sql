-- summarize file stats for file extensions by collection
-- this is kind of slow, but typically we'll be using specific collection ids
CREATE OR REPLACE VIEW view_file_extension_stats_by_collection AS
  SELECT
    FE.id AS file_extension_id,
    FE.extension AS extension,
    P.collection_id AS collection_id,
    COALESCE(SUM(COALESCE(F.size, 0)), 0) AS file_size,
    COUNT(F.id) AS file_count
  FROM file_extensions FE
    JOIN cfs_files F ON FE.id = F.file_extension_id
    JOIN view_cfs_files_to_parents P ON F.id = P.cfs_file_id
  GROUP BY FE.id, FE.extension, P.collection_id
  ORDER BY FE.extension;