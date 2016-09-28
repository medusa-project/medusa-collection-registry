-- Used to get counts of files tested by content type (and possibly repository)
CREATE OR REPLACE VIEW view_tested_file_content_type_counts AS
  SELECT
    content_type_id,
    repository_id,
    count(*) AS count
  FROM view_tested_file_relations
  GROUP BY
    content_type_id, repository_id
;