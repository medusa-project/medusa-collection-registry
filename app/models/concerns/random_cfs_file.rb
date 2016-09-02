#Should work for anything that has a cfs_files relation, but no guarantee
require 'active_support/concern'

module RandomCfsFile
  extend ActiveSupport::Concern

  def random_cfs_file(args = {})
    if args[:file_group_ids].present?
      query = self.cfs_files.joins(cfs_directory: {root_cfs_directory: :parent_file_group}).where('file_groups.id': args[:file_group_ids])
      count = query.count
      query.order(:name).offset(rand(count)).first
    elsif args[:repository_id].present?
      file_group_ids = Repository.find(args[:repository_id]).collections.collect{|c| c.file_group_ids}.flatten
      self.random_cfs_file(file_group_ids: file_group_ids)
    elsif args[:collection_id].present?
      self.random_cfs_file(file_group_ids: Collection.find(args[:collection_id]).file_group_ids)
    elsif args[:virtual_repository_id].present?
      file_group_ids = VirtualRepository.find(args[:virtual_repository_id]).collections.collect{|c| c.file_group_ids}.flatten
      self.random_cfs_file(file_group_ids: file_group_ids)
    else
      self.cfs_files.order(:name).offset(rand(self.cfs_files.count)).first
    end
  end

end