#This is a probably temporary class to help with getting digital library test data onto the
# medusa-pilot server. We need to preserve the uuids from production, or at least to reapply them.
# So this is to do that. We'll do it for the file group, the owning collection, and all associated
# cfs directories and cfs files. We'll try doing it naively and see if that is sufficiently performant.
module Temp
  class UuidSerializer

    attr_accessor :file_group

    def initialize(file_group)
      self.file_group = file_group
    end

    def serialize(file_name)
      uuids = Hash.new
      uuids[:file_group] = file_group.uuid
      uuids[:collection] = file_group.collection.uuid
      directory_hash = Hash.new
      file_hash = Hash.new
      uuids[:directories] = directory_hash
      uuids[:files] = file_hash
      root_directory = file_group.cfs_directory
      root_path = root_directory.relative_path
      root_directory.each_directory_in_tree do |directory|
        directory_hash[path_from_root(directory.relative_path, root_path)] = directory.uuid
      end
      root_directory.each_file_in_tree do |file|
        next if file.nil?

        file_hash[path_from_root(file.relative_path, root_path)] = file.uuid
      end
      File.open(file_name, 'w') do |f|
        f.puts uuids.to_json
      end
    end

    def destroy_uuid(uuid)
      medusa_uuid = MedusaUuid.find_by(uuid: uuid)
      medusa_uuid.destroy! if medusa_uuid
    end

    def unserialize(file_name)
      uuids = JSON.parse(File.read(file_name))
      destroy_uuid(uuids['file_group'])
      file_group.uuid = uuids['file_group'] 
      destroy_uuid(uuids['collection'])
      file_group.collection.uuid = uuids['collection'] 
      root_directory = file_group.cfs_directory
      root_path = root_directory.relative_path
      File.open('errors.txt', 'w') do |errors|
        root_directory.each_directory_in_tree do |directory|
          FileGroup.transaction do
            new_uuid = uuids['directories'][path_from_root(directory.relative_path, root_path)]
            if new_uuid
              destroy_uuid(new_uuid)
              directory.uuid = new_uuid
            else
              errors.puts "Uuid not found for directory #{directory.relative_path}"
            end
          end
        end
        root_directory.each_file_in_tree do |file|
          next if file.nil?

          FileGroup.transaction do
            new_uuid = uuids['files'][path_from_root(file.relative_path, root_path)]
            if new_uuid
              destroy_uuid(new_uuid)
              file.uuid = new_uuid
            else
              errors.puts "Uuid not found for file #{file.relative_path}"
            end
          end
        end
      end
    end

    def path_from_root(path, root_path)
      path.gsub(/^#{root_path}/, '')
    end

  end
end
