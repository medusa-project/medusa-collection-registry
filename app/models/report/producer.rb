class Report::Producer

  attr_accessor :producer, :result

  def initialize(producer)
    self.producer = producer
  end

  def csv
    get_data
    csv = CSV.new('')
    csv << result.columns
    result.each do |row|
      csv << row.values
    end
    csv.string
  end

  def get_data
    self.result = Producer.connection.select_all(sql)
  end

  def sql
    <<SQL
SELECT P.id AS producer_id,
       R.id AS repository_id,
       R.title AS repository_title,
       C.id AS collection_id,
       C.title AS collection_title,
       extract(year FROM F.created_at) AS year,
       extract(month FROM F.created_at) AS month,
       round(COALESCE(SUM(COALESCE(F.size, 0)), 0) / (2.0 ^ 30), 2) AS size_gb,
       COUNT(*) AS count
FROM producers P,
     file_groups FG,
     collections C,
     repositories R,
     -- root directories
     cfs_directories RD,
     -- all directories
     cfs_directories D,
     cfs_files F
WHERE P.id = FG.producer_id
AND   FG.type = 'BitLevelFileGroup'
AND   FG.collection_id = C.id
AND   C.repository_id = R.id
AND   RD.parent_id = FG.id
AND   RD.parent_type = 'FileGroup'
AND   D.root_cfs_directory_id = RD.id
AND   F.cfs_directory_id = D.id
AND   P.id = #{producer.id}
GROUP BY
      P.id,
      C.id,
      C.title,
      R.id,
      R.title,
      year,
      month
ORDER BY
      year ASC,
      month ASC,
      producer_id ASC,
      repository_id ASC,
      collection_id ASC
;
SQL

  end

end