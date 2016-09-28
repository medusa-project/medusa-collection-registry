-- summarize file stats for content types by collection
-- this is kind of slow, but typically we'll be using specific collection ids
CREATE OR REPLACE VIEW view_file_content_type_stats_by_collection AS
  SELECT
    CT.id AS content_type_id,
    CT.name AS name,
    P.collection_id AS collection_id,
    COALESCE(SUM(COALESCE(F.size, 0)), 0) AS file_size,
    COUNT(F.id) AS file_count
  FROM content_types CT
    JOIN cfs_files F ON CT.id = F.content_type_id
    JOIN view_cfs_files_to_parents P ON F.id = P.cfs_file_id
  GROUP BY CT.id, CT.name, P.collection_id
  ORDER BY CT.name;