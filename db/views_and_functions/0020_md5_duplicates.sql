CREATE OR REPLACE VIEW view_cfs_files_summary
  AS
    SELECT
      F.md5_sum,
      V.cfs_file_id,
      V.cfs_directory_id,
      V.file_group_id,
      V.collection_id,
      V.repository_id,
      U.uuid,
      F.name,
      cfs_file_relative_path(F.id) AS relative_path,
      C.name                       AS content_type,
      F.mtime,
      F.size
    FROM view_cfs_files_to_parents V,
      cfs_files F,
      medusa_uuids U,
      content_types C
    WHERE F.id = V.cfs_file_id
          AND U.uuidable_type = 'CfsFile'
          AND U.uuidable_id = F.id
          AND F.content_type_id = C.id
;

CREATE OR REPLACE VIEW view_md5_duplicates
  AS
    SELECT V.*
    FROM
      view_cfs_files_summary V
    WHERE V.md5_sum IN
          (SELECT md5_sum
           FROM
             (SELECT
                md5_sum,
                count(*)
              FROM cfs_files
              GROUP BY md5_sum
              HAVING count(*) > 1) AS duplicates)
;

DROP VIEW IF EXISTS md5_duplicates;