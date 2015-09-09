-- direct mapping of cfs files to their file group for those that have one
CREATE OR REPLACE VIEW cfs_files_to_file_groups AS
SELECT f.id AS cfs_file_id,
    fg.id AS file_group_id
   FROM cfs_files f,
    cfs_directories d,
    cfs_directories rd,
    file_groups fg
  WHERE f.cfs_directory_id = d.id AND d.root_cfs_directory_id = rd.id AND rd.parent_id = fg.id;
