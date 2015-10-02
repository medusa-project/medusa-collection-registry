-- summarize file stats for file extensions by repository
-- this is kind of slow, but typically we'll be using a specific repository id
CREATE OR REPLACE VIEW view_file_extension_stats_by_repository AS
  SELECT
    FE.id AS file_extension_id,
    FE.extension AS extension,
    P.repository_id AS repository_id,
    SUM(F.size) AS file_size,
    COUNT(F.id) AS file_count
  FROM file_extensions FE
    JOIN cfs_files F ON FE.id = F.file_extension_id
    JOIN view_cfs_files_to_parents P ON F.id = P.cfs_file_id
  GROUP BY FE.id, FE.extension, P.repository_id
  ORDER BY FE.extension;