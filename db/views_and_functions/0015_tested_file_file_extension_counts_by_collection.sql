-- Used to get counts of files tested by file extension (and possibly collection)
CREATE OR REPLACE VIEW view_tested_file_file_extension_counts_by_collection AS
  SELECT
    file_extension_id,
    collection_id,
    count(*) AS count
  FROM view_tested_file_relations
  GROUP BY
    file_extension_id, collection_id
;