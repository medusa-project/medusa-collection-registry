-- Used to get counts of files tested by file extension (and possibly repository)
CREATE OR REPLACE VIEW view_tested_file_file_extension_counts AS
  SELECT
    file_extension_id,
    repository_id,
    count(*) AS count
  FROM view_tested_file_relations
  GROUP BY
    file_extension_id, repository_id
;