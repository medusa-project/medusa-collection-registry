#Designed to produce a report on what in a directory has been ingested (according
#to db records) and where. Very specifically targeted at a particular use (to decide
#what staging directories could be deleted that failed to auto-delete), but perhaps
#more generally useful. Computes the md5 and base filename of each file in the
#staging tree. Looks up matching files from the db and their file groups.
#Reports how many files were on disk, which if any were not found in db records,
#and which file groups contained them (and how many, since a file could be ingested
# more than once). Looking for no missing files and one file group that contains
#all of them.

require 'rake'
require 'progress_bar'

namespace :staging_delete do
  desc 'Check potential deletable directory'
  task check_dir: :environment do
    STAGING_DIR = '/mnt/medusa-staging-2'
    DIR = ENV['STAGING_DIR'] or raise RuntimeError, 'Must set STAGING_DIR env var'
    staging_dir = File.join(STAGING_DIR, DIR)
    puts staging_dir
    disk_files = get_disk_files(staging_dir)
    puts "Total Disk files: #{disk_files.keys.count}"
    add_db_info(disk_files)
    missing_files = disk_files.select do |file, info|
      info[:db_files].blank?
    end
    puts "Disk files missing db files: #{missing_files.keys.count}"
    missing_files.keys.each do |f|
      puts "\t#{f}"
    end
    file_group_count_hash = make_file_group_count_hash(disk_files)
    puts "File group counts:"
    file_group_count_hash.each do |id, count|
      puts "\t#{id}: #{count}"
    end
  end
end

def make_file_group_count_hash(files)
  file_group_id_hash = files.values.
                       collect{|info| info[:file_groups]}.flatten.
                       group_by(&:itself)
  Hash.new.tap do |h|
    file_group_id_hash.each do |id, ids|
      h[id] = ids.count
    end
  end

end

def get_disk_files(dir)
  Hash.new.tap do |files|
    Dir.chdir(dir) do
      count = IO.popen("find . -type f | wc") do |find_io|
        find_io.each_line.first.split(/\s+/)[1].to_i
      end
      $stderr.puts "Getting disk files"
      bar = ProgressBar.new(count)
      IO.popen("find . -type f -print0 | xargs -0 md5sum") do |find_io|
        find_io.each_line do |line|
          line.match(/^(\w+)\s+(.*)$/)
          filename = $2
          md5 = $1
          files[filename.sub(/\.\//, '')] = {md5: md5,
                                             basename: File.basename(filename)}
          bar.increment!
        end
      end
    end
  end
end

def add_db_info(files)
  $stderr.puts "Getting db files and file groups"
  bar = ProgressBar.new(files.count)
  files.each do |file, info|
    db_files = CfsFile.where(md5_sum: info[:md5], name: info[:basename]).all.to_a
    info[:db_files] = db_files.collect {|f| f.id}
    file_groups = db_files.collect {|f| f.file_group.try(:id)}.flatten.uniq
    info[:file_groups] = file_groups
    bar.increment!
  end
end

# def add_file_groups_remove_db_files(files)
#   $stderr.puts "Getting file groups"
#   bar = ProgressBar.new(files.count)
#   files.each do |file, info|
#     file_groups = info[:db_files].collect {|f| f.file_group.try(:id)}.flatten.uniq
#     info[:file_groups] = file_groups
#     bar.increment!
#   end
# end
