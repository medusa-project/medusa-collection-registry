class Report::CfsDirectoryMap

  attr_accessor :root_cfs_directory, :storage_path

  def initialize(cfs_directory)
    self.root_cfs_directory = cfs_directory
  end

  def generate(storage_path)
    self.storage_path = storage_path
    add_header
    print_directory(root_cfs_directory)
  end

  def add_header
    File.open(self.storage_path, "a" ) do |f|
      f.puts root_cfs_directory.parent.breadcrumbs.collect(&:breadcrumb_label).join(' > ')
      f.puts "Exported #{Time.now}"
      f.puts
    end
  end

  def print_directory(cfs_directory, level: 0, last: false, prefix: '')
    label = if cfs_directory == root_cfs_directory
              cfs_directory.relative_path
            else
              cfs_directory.path
            end
    subdirectory_count = cfs_directory.subdirectories.count

    File.open(self.storage_path, "a" ) do |f|
      f.write prefix
      f.write directory_marker(level, last)
      f.puts label
      file_info(cfs_directory).each do |file_info|
        f.write prefix
        unless level.zero?
          if last
            f.write '    '
          else
            f.write '│   '
          end
        end
        if subdirectory_count.zero?
          f.write '    '
        else
          f.write '│   '
        end
        f.puts file_info
      end
    end

    cfs_directory.subdirectories.each.with_index do |subdirectory, i|
      last_subdir = i == (subdirectory_count - 1)
      new_prefix = if level.zero?
                     ''
                   elsif last
                     prefix + '    '
                   else
                     prefix + '│   '
                   end
      print_directory(subdirectory, level: level + 1, last: last_subdir, prefix: new_prefix)
    end
    cfs_directory.subdirectories.reset
  end

  def directory_marker(level, last)
    return '' if level == 0
    last ? '└───' : '├───'
  end

  def generate_hash(cfs_directory)
    label = if cfs_directory == root_cfs_directory
              cfs_directory.relative_path
            else
              cfs_directory.path
            end
    subtree = file_info(cfs_directory) + subdirectory_info(cfs_directory)
    {label => subtree}
  end

  def subdirectory_info(cfs_directory)
    subdirectory_info = cfs_directory.subdirectories.order(:path).collect {|subdirectory| generate_hash(subdirectory)}
    cfs_directory.subdirectories.reset
    subdirectory_info
  end

  def file_info(cfs_directory)
    files = cfs_directory.cfs_files.order(:name).includes(:content_type).all
    return [] if files.blank?
    content_type_groups = files.group_by {|cfs_file| cfs_file.content_type.name}
    results = Hash.new
    content_type_groups.each do |content_type, content_type_group|
      count = content_type_group.count
      size = ActiveSupport::NumberHelper.number_to_human_size(content_type_group.sum(&:size))
      some_files = content_type_group.first(3).collect(&:name).join(', ')
      some_files = some_files + "..." if count > 3
      results["* #{content_type}"] = "(#{count})\t#{size}\t#{some_files}"
    end
    max_length = results.keys.max_by(&:length).length
    file_info = results.keys.sort.collect do |key|
      "#{key}#{" " * (max_length - key.length + 2)}#{results[key]}"
    end
    cfs_directory.cfs_files.reset
    file_info << ''
  end

end