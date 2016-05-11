module CfsDirectoriesHelper

  def add_cfs_directory_tree_csv_headers(csv)
    csv << %w(uuid type name parent_directory_uuid parent_directory_name md5_sum content_type size mtime relative_pathname)
  end

  def add_cfs_directory_tree_entries(csv, root_cfs_directory)
    ids = root_cfs_directory.recursive_subdirectory_ids
    CfsDirectory.where(id: ids).includes(:medusa_uuid, :parent).find_each do |cfs_directory|
      parent = cfs_directory.parent
      csv << Array.new.tap do |row|
        row << cfs_directory.uuid
        row << 'folder'
        row << cfs_directory.path
        if parent.is_a?(CfsDirectory)
          row << parent.uuid
          row << parent.path
        else
           row << ''
           row << ''
        end
        row << ''
        row << ''
        row << cfs_directory.tree_size
        row << ''
        row << cfs_directory.relative_path
      end
      add_cfs_directory_tree_csv_files(csv, cfs_directory)
    end
  end

  def add_cfs_directory_tree_csv_files(csv, cfs_directory)
    cfs_directory_relative_path = cfs_directory.relative_path
    cfs_directory.cfs_files.includes(:content_type, :medusa_uuid).each do |file|
      csv << Array.new.tap do |row|
        row << file.uuid
        row << 'file'
        row << file.name
        row << cfs_directory.uuid
        row << cfs_directory.path
        row << file.md5_sum
        row << file.content_type_name
        row << file.size
        row << file.mtime
        row << File.join(cfs_directory_relative_path, file.name)
      end
    end
    cfs_directory.cfs_files.reset
  end

end