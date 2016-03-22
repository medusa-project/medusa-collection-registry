class GlacierAnalysis::Archive < Object

  attr_accessor :id, :size, :creation_time, :description
  attr_accessor :repository_id, :collection_id, :file_group_id, :cfs_directory_id

  def initialize(archive_json)
    self.id = archive_json['ArchiveId']
    self.size = archive_json['Size']
    self.creation_time = Time.parse(archive_json['CreationDate'])
    self.description = Base64.decode64(archive_json['ArchiveDescription'])
    self.extract_medusa_info
  end

  def extract_medusa_info
    self.repository_id = self.extract_id_from_description(/Repository Id: (\d+)/)
    self.collection_id = self.extract_id_from_description(/Collection Id: (\d+)/)
    self.file_group_id = self.extract_id_from_description(/File Group Id: (\d+)/)
    self.cfs_directory_id = self.extract_id_from_description(/Cfs Directory Id: (\d+)/)
  end

  def file_group
    file_group_id.present? ? FileGroup.find(file_group_id) : nil
  end

  protected

  #return the first matching result from description given the regexp
  def extract_id_from_description(regexp)
    self.description.match(regexp)[1].to_i rescue nil
  end

end