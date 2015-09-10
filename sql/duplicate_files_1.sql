-- it's unclear what the best way to do this will be
-- this one detects duplicate files that are in more than one file
-- group  (via the max/min trick) and orders by their size
SELECT F.name, F.md5_sum, F.size, max(FTFG.file_group_id) AS max,
min(FTFG.file_group_id) AS min, count(*) as count
FROM cfs_files F
JOIN cfs_files_to_file_groups FTFG ON F.id=FTFG.cfs_file_id
GROUP BY F.name, F.md5_sum, F.size
HAVING count(*) > 1 AND max(FTFG.file_group_id) != min(FTFG.file_group_id)
ORDER BY F.size	DESC
;
