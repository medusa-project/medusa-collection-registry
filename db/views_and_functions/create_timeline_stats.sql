CREATE OR REPLACE FUNCTION create_timeline_stats() RETURNS VOID AS $$
  DROP TABLE IF EXISTS timeline_stats;
  CREATE TABLE timeline_stats AS
    SELECT month, count(*) AS count, coalesce(sum(size), 0) FROM
      (SELECT id, date_trunc('month', created_at) AS month, size FROM cfs_files) AS S
    GROUP BY month;
$$ LANGUAGE SQL;

