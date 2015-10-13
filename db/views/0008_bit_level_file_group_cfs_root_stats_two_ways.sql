-- comparison of BLFG total_file_size and total_files with corresponding cfs_directory tree_size and tree_count
-- note - on the file group side this is stored in GB, so we normalize back to bytes here.
CREATE OR REPLACE VIEW view_bit_level_file_group_cfs_root_stats_two_ways AS
  SELECT FG.id AS file_group_id, round(FG.total_file_size * 1073741824) AS file_group_size, FG.total_files AS file_group_count,
         D.id AS cfs_directory_id, D.tree_size AS cfs_directory_size, D.tree_count AS cfs_directory_count
  FROM file_groups FG LEFT JOIN cfs_directories D ON FG.id = D.parent_id
  WHERE D.parent_type = 'FileGroup'
;