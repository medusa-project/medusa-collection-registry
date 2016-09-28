-- cfs directories where either the size or count stats are off
-- now that these are done by triggers and the stats are synchronized this shouldn't ever
-- give any results. Useful to run anyway because if it does there is a bug somewhere!
CREATE OR REPLACE VIEW view_cfs_directories_inconsistent_file_stats AS
  SELECT * FROM view_cfs_directories_file_stats_two_ways
  WHERE tree_count != computed_count OR tree_size != computed_size
;

