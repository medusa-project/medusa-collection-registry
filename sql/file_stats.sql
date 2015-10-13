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

-- cfs directories where either the size or count stats are off
CREATE OR REPLACE VIEW view_cfs_directories_inconsistent_file_stats AS
SELECT * FROM view_cfs_directories_file_stats_two_ways
WHERE tree_count != computed_count OR tree_size != computed_size
;

-- comparison of BLFG total_file_size and total_files with corresponding cfs_directory tree_size and tree_count
-- note - on the file group side at one time this was stored in GB rather than raw bytes, which I'm trying to change!
CREATE OR REPLACE VIEW view_bit_level_file_group_cfs_root_stats_two_ways AS
SELECT FG.id AS file_group_id, FG.total_file_size AS file_group_size, FG.total_files AS file_group_count,
  D.id AS cfs_directory_id, D.tree_size AS cfs_directory_size, D.tree_count AS cfs_directory_count
FROM file_groups FG LEFT JOIN cfs_directories D ON FG.id = D.parent_id
WHERE D.parent_type = 'FileGroup'
;