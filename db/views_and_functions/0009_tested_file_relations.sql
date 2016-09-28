-- Add some context to file_format_test data. Used by dashboards to get counts of tested files of various types
CREATE OR REPLACE VIEW view_tested_file_relations AS
  SELECT
    FFT.id AS file_format_test_id,
    F.id AS cfs_file_id,
    F.content_type_id,
    F.file_extension_id,
    P.repository_id,
    P.collection_id
  FROM
    file_format_tests FFT JOIN
    cfs_files F ON FFT.cfs_file_id=F.id JOIN
    view_cfs_files_to_parents P ON F.id=P.cfs_file_id
;