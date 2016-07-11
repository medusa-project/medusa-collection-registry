#simple comparison - take source and target directories (named because of our usage, nothing intrinsic to this class)
#get a list of all files in each along with their sizes
#allow showing which is in just the source, in just the target, or in both but with different sizes
#Obviously this is not the most efficient way to do, but it's clear
require 'find'
require 'open3'
class DirectoryTreeComparator < Object

  attr_accessor :source_directory, :target_directory, :all_paths, :source_only_paths,
                :target_only_paths, :different_sizes_paths

  def initialize(source_directory, target_directory)
    self.source_directory = source_directory
    self.target_directory = target_directory
    self.analyze
  end

  def analyze
    augment_all_paths(source_directory, :source)
    augment_all_paths(target_directory, :target)
    create_source_only_paths
    create_target_only_paths
    create_different_sizes_paths
  end

  def augment_all_paths(directory, size_key)
    self.all_paths ||= Hash.new
    Dir.chdir(directory) do
      Open3.popen2(find_command, '.', '-type', 'f', '-exec', stat_command, '-c', '"%n %s"', '{}', ';') do |stdin, stdout, wait|
        stdout.each_line do |line|
          normalized_entry = line.chomp.sub(/^\.\//, '')
          normalized_entry.match(/^(.*) (\d+)$/)
          all_paths[$1] ||= Hash.new
          all_paths[$1][size_key] = $2.to_i
        end
      end
    end
  end

  #find/gfind <dir> -type f -exec stat/gstat -c "%n %s" {} \;

  def find_command
    if OS.linux?
      'find'
    elsif OS.mac?
      'gfind'
    else
      raise RuntimeError, "Unrecognized platform"
    end
  end

  def stat_command
    if OS.linux?
      'stat'
    elsif OS.mac?
      'gstat'
    else
      raise RuntimeError, "Unrecognized platform"
    end
  end

  def create_source_only_paths
    self.source_only_paths = all_paths.select { |path, sizes| sizes[:target].blank? }.keys
  end

  def create_target_only_paths
    self.target_only_paths = all_paths.select { |path, sizes| sizes[:source].blank? }.keys
  end

  def create_different_sizes_paths
    self.different_sizes_paths = all_paths.select { |path, sizes| sizes[:target].present? and sizes[:source].present? and sizes[:target] != sizes[:source] }
  end

  def directories_equal?
    source_only_paths.blank? and target_only_paths.blank? and different_sizes_paths.blank?
  end

end
