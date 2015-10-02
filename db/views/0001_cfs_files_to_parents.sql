-- direct mapping of cfs files to their cfs_directory, root cfs directory,
-- file group, collection, repository, and institution
CREATE OR REPLACE VIEW cfs_files_to_parents AS
  SELECT
    f.id  AS cfs_file_id,
    d.id AS cfs_directory_id,
    rd.id AS root_cfs_directory_id,
    fg.id AS file_group_id,
    c.id AS collection_id,
    r.id AS repository_id,
    r.institution_id AS institution_id
  FROM cfs_files f,
    cfs_directories d,
    cfs_directories rd,
    file_groups fg,
    collections c,
    repositories r
  WHERE f.cfs_directory_id = d.id
        AND d.root_cfs_directory_id = rd.id
        AND rd.parent_id = fg.id
        AND fg.collection_id = c.id
        AND c.repository_id = r.id;
