require 'rake'

namespace :check do
  desc 'Run all checks'
  task :all => [:cfs_directories_vs_bit_level_file_groups, :file_count_and_size_totals,
                :cfs_directories_vs_physical_paths] do
    #just run all dependencies
  end

  desc 'Find root cfs directories with no file group and vice-versa'
  task cfs_directories_vs_bit_level_file_groups: :environment do
    #find and display root cfs directories with no file group
    puts "\nCfs Directories without associated Bit Level File Group"
    puts "Id,Path,FileCount"
    CfsDirectory.roots.find_each do |cfs_directory|
      next if cfs_directory.file_group.present?
      puts "#{cfs_directory.id},#{cfs_directory.path},#{cfs_directory.tree_count}"
    end
    #find and display bit level file groups with no cfs directory
    puts "\nBit Level File Groups without associated Cfs Directory"
    puts "Id,Name,CollectionId,CollectionTitle"
    BitLevelFileGroup.find_each do |file_group|
      next if file_group.cfs_directory.present?
      puts "#{file_group.id},#{file_group.name},#{file_group.collection.id},#{file_group.collection.title}"
    end
  end

  desc 'Compare file and size totals computed in different ways'
  task file_count_and_size_totals: :environment do
    puts "Method,FileCount,FileSize"
    puts "CfsFile objects,#{CfsFile.count},#{CfsFile.sum(:size)}"
    puts "ContentType objects,#{ContentType.sum(:cfs_file_count)},#{ContentType.sum(:cfs_file_size)}"
    roots = CfsDirectory.roots
    puts "RootCfsDirectories,#{roots.sum(:tree_count)},#{roots.sum(:tree_size)}"
    puts "BitLevelFileGroups,#{BitLevelFileGroup.sum(:total_files)},#{BitLevelFileGroup.sum(:total_file_size)}"
  end

  desc 'Find cfs directories with no physical path and vice-versa'
  task cfs_directories_vs_physical_paths: :environment do
    #find cfs directories with no physical path
    puts "\nCfs Directory objects without a physical directory"
    puts "Id,Path"
    CfsDirectory.roots.find_each do |cfs_directory|
      next if File.directory?(cfs_directory.absolute_path)
      puts "#{cfs_directory.id},#{cfs_directory.path}"
    end
    #find physical paths with no cfs directory
    puts "\nPhysical potential cfs directories without Cfs Directory object"
    puts "Path"
    CfsRoot.instance.non_cached_physical_root_set.each do |path|
      next if CfsDirectory.find_by(path: path)
      puts path
    end
  end
end