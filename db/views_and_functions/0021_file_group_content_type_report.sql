CREATE OR REPLACE FUNCTION file_group_content_type_report(file_group_id INT, start INT, count INT)
  RETURNS TABLE(cfs_file_id INT, content_type_name VARCHAR, cfs_file_relative_path VARCHAR, uuid VARCHAR) AS $$
SELECT
  V.cfs_file_id,
  CT.name,
  cfs_file_relative_path(F.id),
  U.uuid
FROM view_cfs_files_to_parents V,
  cfs_files F,
  content_types CT,
  medusa_uuids U
WHERE V.file_group_id = $1
      AND V.cfs_file_id = F.id
      AND F.content_type_id = CT.id
      AND F.id = U.uuidable_id
      AND U.uuidable_type = 'CfsFile'
ORDER BY F.id
LIMIT $3
OFFSET $2
$$ LANGUAGE SQL;