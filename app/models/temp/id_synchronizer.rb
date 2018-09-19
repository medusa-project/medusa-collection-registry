#This is to synchronize the ids of file groups and collections with production as needed for DLS tests on pilot
# This class is to handle doing the database/solr work of changing the ids. A small amount of file system manipulation
# will also be necessary to move the actual content.
class Temp::IdSynchronizer

  attr_accessor :old_file_group_id, :new_file_group_id, :old_collection_id, :new_collection_id, :file_group, :collection

  def initialize(args = {})
    self.old_file_group_id = args[:old_file_group_id] || (raise "Must provide old file group id")
    self.old_collection_id = args[:old_collection_id] || (raise "Must provide old collection id")
    self.new_file_group_id = args[:new_file_group_id] || (raise "Must provide new file group id")
    self.new_collection_id = args[:new_collection_id] || (raise "Must provide new collection id")
    self.file_group = FileGroup.find(old_file_group_id) || (raise "File group not found")
    self.collection = Collection.find(old_collection_id) || (raise "Collection not found")
  end

  def process
    self.collection.transaction do
      update_file_group_id(file_group.rights_declaration, id_field: :rights_declarable_id)
      update_collection_id(collection.rights_declaration, id_field: :rights_declarable_id)
      collection.access_system_collection_joins.each do |join|
        update_collection_id(join)
      end
      collection.collection_virtual_repository_joins.each do |join|
        update_collection_id(join)
      end
      collection.projects.each do |project|
        update_collection_id(project)
      end
      collection.child_collection_joins.each do |join|
        update_collection_id(join, id_field: :parent_collection_id)
      end
      collection.parent_collection_joins.each do |join|
        update_collection_id(join, id_field: :child_collection_id)
      end
      collection.assessments.each do |assessment|
        update_collection_id(assessment, id_field: :assessable_id)
      end
      collection.attachments.each do |attachment|
        update_collection_id(attachment, id_field: :attachable_id)
      end

      if file_group.storage_level == 'bit-level store'
        file_group.archived_accrual_jobs.each do |job|
          update_file_group_id(job)
        end
        file_group.job_cfs_initial_directory_assessments.each do |job|
          update_file_group_id(job)
        end
        file_group.job_fits_directories.each do |job|
          update_file_group_id(job)
        end
      end
      file_group.target_file_group_joins.each do |join|
        update_file_group_id(join, id_field: :source_file_group_id)
      end
      file_group.source_file_group_joins.each do |join|
        update_file_group_id(join, id_field: :target_file_group_id)
      end
      file_group.assessments.each do |assessment|
        update_file_group_id(assessment, id_field: :assessable_id)
      end
      file_group.attachments.each do |attachment|
        update_file_group_id(attachment, id_field: :attachable_id)
      end
      update_file_group_id(file_group.cfs_directory, id_field: :parent_id) if file_group.cfs_directory.present?

      collection.file_groups.each do |file_group|
        update_collection_id(file_group)
      end

      file_group.cfs_directory.update_column(:path, "#{new_collection_id}/#{new_file_group_id}")
      file_group.update_column(:id, new_file_group_id)
      collection.update_column(:id, new_collection_id)
      Collection.connection.execute("select update_cache_content_type_stats_by_collection()")
      Collection.connection.execute("select update_cache_file_extension_stats_by_collection()")
      #raise 'Abort until we have everything in place'
    end
  end

  def update_collection_id(object, id_field: :collection_id)
    object.update_column(id_field, new_collection_id)
  end

  def update_file_group_id(object, id_field: :file_group_id)
    object.update_column(id_field, new_file_group_id)
  end

end