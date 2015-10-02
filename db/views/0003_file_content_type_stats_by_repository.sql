-- summarize file stats for content types by repository
-- this is kind of slow, but typically we'll be using a specific repository id
CREATE OR REPLACE VIEW view_file_content_type_stats_by_repository AS
  SELECT
    CT.id AS content_type_id,
    CT.name AS name,
    P.repository_id AS repository_id,
    SUM(F.size) AS file_size,
    COUNT(F.id) AS file_count
  FROM content_types CT
    JOIN cfs_files F ON CT.id = F.content_type_id
    JOIN view_cfs_files_to_parents P ON F.id = P.cfs_file_id
  GROUP BY CT.id, CT.name, P.repository_id
  ORDER BY CT.name;