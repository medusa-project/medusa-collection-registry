CREATE OR REPLACE VIEW view_file_groups_latest_amazon_backup AS
SELECT
  FG.id AS file_group_id,
  AB.part_count,
  AB.archive_ids,
  AB.date,
  R.id AS repository_id
FROM amazon_backups AB,
  (SELECT
     cfs_directory_id,
     MAX(date) AS max_date
   FROM amazon_backups
   GROUP BY cfs_directory_id) ABLU,
  cfs_directories CFS, file_groups FG, Collections C, Repositories R
WHERE AB.cfs_directory_id = ABLU.cfs_directory_id AND AB.date = ABLU.max_date AND AB.part_count IS NOT NULL
      AND AB.archive_ids IS NOT NULL AND CFS.id = AB.cfs_directory_id
      AND FG.id = CFS.parent_id AND CFS.parent_type = 'FileGroup'
      AND FG.collection_id = C.id AND C.repository_id = R.id;