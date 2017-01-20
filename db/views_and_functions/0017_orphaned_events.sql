-- Find events whose eventable no longer exists
CREATE OR REPLACE VIEW orphaned_events AS
(SELECT E.id
 FROM events E LEFT JOIN cfs_files EVT ON E.eventable_id = EVT.id
 WHERE E.eventable_type = 'CfsFile'
       AND EVT.id IS NULL)
UNION
(SELECT E.id
 FROM events E LEFT JOIN cfs_directories EVT ON E.eventable_id = EVT.id
 WHERE E.eventable_type = 'CfsDirectory'
       AND EVT.id IS NULL)
UNION
(SELECT E.id
 FROM events E LEFT JOIN file_groups EVT ON E.eventable_id = EVT.id
 WHERE E.eventable_type = 'FileGroup'
       AND EVT.id IS NULL)
UNION
(SELECT E.id
 FROM events E LEFT JOIN collections EVT ON E.eventable_id = EVT.id
 WHERE E.eventable_type = 'Collection'
       AND EVT.id IS NULL)
UNION
(SELECT E.id
 FROM events E LEFT JOIN repositories EVT ON E.eventable_id = EVT.id
 WHERE E.eventable_type = 'Repository'
       AND EVT.id IS NULL)
 ;
