-- summarize file stats for file extensions by collection
-- this is kind of slow, but typically we'll be using specific collection ids
DROP VIEW IF EXISTS view_file_extension_stats_by_collection;
CREATE OR REPLACE VIEW view_file_extension_stats_by_collection AS
  SELECT V.collection_id AS collection_id,
    FE.id AS file_extension_id,
    FE.extension AS extension,
    COUNT(*) AS file_count,
    COALESCE(SUM(COALESCE(F.size, 0))) AS file_size
  FROM cfs_files F, view_cfs_files_to_parents V, file_extensions FE
  WHERE F.id = V.cfs_file_id
        AND F.file_extension_id = FE.id
  GROUP BY V.collection_id, FE.id, FE.extension
;
