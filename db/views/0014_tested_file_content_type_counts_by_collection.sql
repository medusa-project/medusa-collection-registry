-- Used to get counts of files tested by content type (and possibly collection)
CREATE OR REPLACE VIEW view_tested_file_content_type_counts_by_collection AS
  SELECT
    content_type_id,
    collection_id,
    count(*) AS count
  FROM view_tested_file_relations
  GROUP BY
    content_type_id, collection_id
;