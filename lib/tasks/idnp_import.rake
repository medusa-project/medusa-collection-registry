#This is just a temporary file for a single task, to go away after it is done
require 'rake'

namespace :idnp do

  desc "Create imports for IDNP content"
  task create_imports: :environment do
    staging_root = 'ADS_Staging'
    storage_root = AccrualStorage.instance.root_named(staging_root)
    directories = storage_root.directories_at('IDNP_RestructuredCollections')
    directories.each.with_index do |directory_pathname, i|
      next unless directory_pathname.basename.to_s == "1015-sn84024082"
      base_name = directory_pathname.basename.to_s
      collection_id = base_name.match(/^(\d+)-/)[1]
      collection = Collection.find(collection_id) || (raise RuntimeError, "Collection #{collection_id} not found.")
      puts "Found #{collection_id} #{i}"
      file_group = BitLevelFileGroup.new(collection_id: collection.id, title: 'Restructured Content', type: 'BitLevelFileGroup',
                                 producer_id: 24)
      file_group.rights_declaration = file_group.clone_collection_rights_declaration
      raise RuntimeError, "Invalid file group for collection #{collection_id}" unless file_group.valid?
      if file_group.save
        file_group.record_creation_event(User.find_by(uid: 'hding2@illinois.edu'))
        file_group.ensure_cfs_directory
      else
        raise RuntimeError, "Unable to create file group for directory #{base_name}"
      end

      file_group.reload
      # create accrual request (for the subdirs), event
      #
      accrual_directories = directory_pathname.children.collect {|c| c.basename.to_s}
      staging_path = "/#{staging_root}/IDNP_RestructuredCollections/#{base_name}"
      puts "Accrual dirs: #{accrual_directories}"
      puts "Staging path: #{staging_path}"
      Workflow::AccrualJob.create_for(User.find_by(uid: 'ccniels2@illinois.edu'), file_group.cfs_directory, staging_path,
                                      [], accrual_directories, true)
      puts "Done: #{collection_id} #{i}"
    end
  end


end