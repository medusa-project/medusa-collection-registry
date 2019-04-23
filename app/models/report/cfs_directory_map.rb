class Report::CfsDirectoryMap

  attr_accessor :root_cfs_directory, :io

  def initialize(cfs_directory)
    self.root_cfs_directory = cfs_directory
  end

  def generate(io)
    self.io = io
    add_header
    print_directory(root_cfs_directory)
  end

  def add_header
    #io.write "\u00ef\u00bb\u00bf"
    io.puts root_cfs_directory.parent.breadcrumbs.collect(&:breadcrumb_label).join(' > ')
    io.puts "Exported #{Time.now}"
    io.puts
  end

  def print_directory(cfs_directory, level: 0, last: false, prefix: '')
    label = if cfs_directory == root_cfs_directory
              cfs_directory.relative_path
            else
              cfs_directory.path
            end
    subdirectory_count = cfs_directory.subdirectories.count
    io.write prefix
    io.write directory_marker(level, last)
    io.puts label
    file_info(cfs_directory).each do |file_info|
      io.write prefix
      unless level.zero?
        if last
          io.write '    '
        else
          io.write '│   '
        end
      end
      if subdirectory_count.zero?
        io.write '    '
      else
        io.write '│   '
      end
      io.puts file_info
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