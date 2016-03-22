class GlacierAnalysis::ArchiveReportAnalyzer < Object

  attr_accessor :report_file, :parsed_json, :archive_list, :archive_hash

  def initialize(report_file)
    self.report_file = report_file
    parse_report_file
  end

  def parse_report_file
    self.parsed_json = JSON.parse(File.read(report_file))
    create_archive_list
    create_archive_hash
  end

  def create_archive_list
    self.archive_list = Array.new
    parsed_json['ArchiveList'].each do |archive_json|
      self.archive_list << GlacierAnalysis::Archive.new(archive_json)
    end
  end

  def create_archive_hash
    self.archive_hash = Hash.new
    self.archive_list.each do |archive|
      archive_hash[archive.file_group_id] ||= Array.new
      archive_hash[archive.file_group_id] << archive
    end
  end

  def report
    output = StringIO.new
    BitLevelFileGroup.order(:id).each do |fg|
      archives = archive_hash[fg.id] || []
      archive_size = archives.inject(0) { |acc, elt| acc + elt.size }
      db_size = fg.total_file_size * 1.gigabyte
      output.puts [fg.id, archives.count, archive_size, db_size, archive_size - db_size].join(',')
    end
    output.string
  end

end