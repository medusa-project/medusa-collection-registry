CREATE OR REPLACE FUNCTION cfs_directory_relative_path(INT)
  RETURNS TEXT AS $$

SELECT CASE WHEN (SELECT parent_type
                  FROM cfs_directories
                  WHERE id = $1) = 'FileGroup'

  THEN

    (SELECT path
     FROM cfs_directories
     WHERE id = $1)

       ELSE

         (SELECT concat(cfs_directory_relative_path(parent_id), '/', path)
          FROM cfs_directories
          WHERE id = $1)

       END

$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION cfs_file_relative_path(INT)
  RETURNS TEXT AS $$

SELECT concat(cfs_directory_relative_path(cfs_directory_id), '/', name)
FROM cfs_files
WHERE id = $1;

$$
LANGUAGE SQL;
