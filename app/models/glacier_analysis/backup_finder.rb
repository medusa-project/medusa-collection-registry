#Some utility to get information about amazon backups for a particular cfs file.
#Recall that the manifest files are named:
#<collection_id>-<#file_group_id>-<#date>
#and the entries are of the form:
#md5sum<space+>data/<path from file group root>
#This is pretty much designed for a specific problem I have right now, but
#may prove to be the start of something more useful.
class GlacierAnalysis::BackupFinder < Object

  attr_accessor :cfs_file

  def initialize(cfs_file)
    self.cfs_file = cfs_file
  end

  def manifest_directory
    Pathname.new(Settings.medusa.amazon.manifest_directory)
  end

  def manifest_prefix
    "#{cfs_file.collection.id}-#{cfs_file.file_group.id}"
  end

  def possible_manifest_files
    manifest_directory.children.select {|child| child.basename.to_s.start_with?(manifest_prefix)}
  end

  #TODO this would live more naturally in CfsFile, possibly with a better name,
  #but is here now so that I can deploy just this file and experiment
  def path_from_file_group_root
    cfs_file.relative_path.gsub(/^#{cfs_file.root_cfs_directory.relative_path}\//, '')
  end

  def single_manifest_data(manifest_path)
    path_target = 'data/' + path_from_file_group_root
    target_regexp = /^(\S+)\s+(#{Regexp.quote(path_target)})$/
    line = File.open(manifest_path) do |manifest|
      manifest.each_line.detect do |line|
        line.chomp!
        line.match(target_regexp)
      end
    end
    if line
      match = line.match(target_regexp)
      [manifest_path, match[1], match[2]]
    else
      nil
    end
  end

  def manifest_data
    raw_manifest_data = possible_manifest_files.collect do |manifest|
      single_manifest_data(manifest)
    end.compact
    puts raw_manifest_data.inspect
    raw_manifest_data.collect do |data|
      manifest_path = data[0]
      md5_sum = data[1]
      {
          manifest_path: manifest_path,
          md5_sum: md5_sum,
          amazon_backup: amazon_backup(manifest_path)
      }
    end
  end

  def manifest_date(manifest_path)
    manifest_path.basename.to_s.match(/(\d+-\d+-\d+)\./)
    Date.parse($1)
  end

  def amazon_backup(manifest_path)
    cfs_file.file_group.amazon_backups.detect {|ab| ab.date == manifest_date(manifest_path)}
  end

end