#This is just a helper to mediate authorization for the
#CfsController
class FitsRequest < Object
  attr_accessor :path

  def initialize(path)
    self.path = path
  end

  #return the repository corresponding to path, or nil if there is none.
  def repository
    self.file_group.try(:repository)
  end

  def file_group
    FileGroup.where('cfs_root IS NOT NULL').where("? LIKE cfs_root || ?", self.path, "%").first
  end

end