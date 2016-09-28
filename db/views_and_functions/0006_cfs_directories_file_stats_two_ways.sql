-- each cfs directory with its stored tree stats for files and size and that computed from its children and their stats
-- can be useful to make sure things are consistent, or to recompute for a given directory
CREATE OR REPLACE VIEW view_cfs_directories_file_stats_two_ways AS
  SELECT id, tree_count, tree_size,
    (SELECT COUNT(*) FROM cfs_files F WHERE F.cfs_directory_id = D.id) +
    (SELECT SUM(COALESCE(tree_count,0)) FROM cfs_directories SD WHERE SD.parent_type = 'CfsDirectory' AND SD.parent_id = D.id) AS computed_count,
    (SELECT SUM(COALESCE(size,0)) FROM cfs_files F WHERE F.cfs_directory_id = D.id) +
    (SELECT SUM(COALESCE(tree_size,0)) FROM cfs_directories SD WHERE SD.parent_type = 'CfsDirectory' AND SD.parent_id = D.id) AS computed_size
  FROM cfs_directories D
;
