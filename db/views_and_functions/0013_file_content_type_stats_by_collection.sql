-- summarize file stats for content types by collection
-- this is kind of slow, but typically we'll be using specific collection ids
DROP VIEW IF EXISTS view_file_content_type_stats_by_collection;
CREATE OR REPLACE VIEW view_file_content_type_stats_by_collection AS
  SELECT V.collection_id AS collection_id,
    CT.id AS content_type_id,
    CT.name AS name,
    COUNT(*) AS file_count,
    COALESCE(SUM(COALESCE(F.size, 0))) AS file_size
  FROM cfs_files F, view_cfs_files_to_parents V, content_types CT
  WHERE F.id = V.cfs_file_id
        AND F.content_type_id = CT.id
  GROUP BY V.collection_id, CT.id, CT.name
;
