require 'tty-tree'
class Report::CfsDirectoryMap

  attr_accessor :root_cfs_directory, :io

  def initialize(cfs_directory)
    self.root_cfs_directory = cfs_directory
  end

  def generate(io)
    self.io = io
    add_header
    tree = TTY::Tree.new(generate_hash(root_cfs_directory))
    io.puts tree.render
  end

  def add_header
    io.puts root_cfs_directory.parent.breadcrumbs.collect(&:breadcrumb_label).join(' > ')
    io.puts "Exported #{Time.now}"
    io.puts
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
    file_info
  end

end