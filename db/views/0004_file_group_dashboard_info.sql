-- information about file group and parents used in the dashboard for amazon information
CREATE OR REPLACE VIEW view_file_group_dashboard_info AS
  SELECT
    FG.id,
    FG.title,
    FG.total_files,
    FG.total_file_size,
    C.id AS collection_id,
    C.title AS collection_title,
    R.id AS repository_id,
    R.title AS repository_title
  FROM file_groups FG, collections C, repositories R, cfs_directories CFS
  WHERE FG.type = 'BitLevelFileGroup' AND FG.collection_id = C.id AND c.repository_id = R.id
        AND CFS.parent_type = 'FileGroup' AND CFS.parent_id = FG.id
  ORDER BY FG.id ASC;