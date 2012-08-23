require 'rake'
require 'csv'

desc 'migrate Access data'
task :access_migrate => :environment do
  #back up current database against failure
  system("pg_dump medusa_#{Rails.env} > #{File.join(Rails.root, "tmp", "medusa_#{Rails.env}.sql")}")
  #read csv as hashes
  @access_systems = read_access_systems
  @repositories = read_repositories
  @production_units = read_production_units
  @file_types = read_file_types
  @collections = read_collections
  @file_groups = read_file_groups
  #[@access_systems, @repositories, @production_units, @file_types, @collections, @file_groups].each {|a| puts a.to_yaml}
  #find/make new objects and save, with associations. Use name/title to fix joins
  ActiveRecord::Base.transaction do
    create_access_systems
    create_repositories
    create_production_units
    create_collections
    create_file_groups
    raise RuntimeError, 'Okay so far - just aborting DB work'
  end
end

def read_access_systems
  @access_systems = read_csv('AccessSystem.csv', [:id, :name])
end

def create_access_systems
  puts "Existing Access Systems: #{AccessSystem.count}"
  puts "Input Size: #{@access_systems.count}"
  @access_systems.each do |as|
    AccessSystem.find_or_create_by_name(as[:name])
  end
  puts "Total Access Systems: #{AccessSystem.count}"
end

def read_repositories
  @repositories = read_csv('Repository.csv', [:id, :title])
end

def create_repositories
  puts "Existing Repositories: #{Repository.count}"
  puts "Input Size: #{@repositories.count}"
  @repositories.each do |r|
    Repository.find_or_create_by_title(r[:title])
  end
  puts "Total Repositories: #{Repository.count}"
end

def read_production_units
  @production_units = read_csv('ProductionUnit.csv', [:id, :title])
end

def create_production_units
  puts "Existing Production Units: #{ProductionUnit.count}"
  puts "Input Size: #{@production_units.count}"
  @production_units.each do |pu|
    ProductionUnit.find_or_create_by_title(pu[:title])
  end
  puts "Total Production Units: #{ProductionUnit.count}"
end

def read_file_types
  @file_types = read_csv('FileType.csv', [:id, :type])
end

def read_collections
  @collections = read_csv('Collection.csv', [:id, :title, :repository_id, nil, nil, nil, nil, :published, :ongoing, :description, :access_system_id, :access_url])
  #postprocess
  #puts "REPOS: #{@repositories.collect {|r| r[:id]}.sort.join(',')}"
  #puts "KEYS: #{@collections.collect {|c| c[:repository_id]}.sort.join(',')}"
  @collections.each do |c|
    #convert booleans
    c[:published] = c[:published] == '1'
    c[:ongoing] = c[:ongoing] == '1'
    #prepare for joins
    c[:repository_title] = @repositories.detect { |r| r[:id] == c[:repository_id] }[:title]
    c[:access_system_name] = @access_systems.detect { |as| as[:id] == c[:access_system_id] }[:name]
  end
end

def create_collections
  puts "Existing Collections: #{Collection.count}"
  puts "Input Size: #{@collections.count}"
  @collections.each do |c|
    repository = Repository.find_by_title(c[:repository_title])
    raise(RuntimeError, "Didn't find repository") unless repository
    collection = Collection.create(:title => c[:title], :repository_id => repository.id, :published => c[:published],
                                   :ongoing => c[:ongoing], :description => c[:description], :access_url => c[:access_url])
    access_system = AccessSystem.find_by_name(c[:access_system_name])
    if access_system
      collection.access_systems << access_system
    end
  end
  puts "Total Collections: #{Collection.count}"
  puts "Associated Access Systems: #{Collection.all.collect { |c| c.access_systems }.flatten.count}"
end

def read_file_groups
  @file_groups = read_csv('FileGroup.csv', [:id, :collection_id, :production_unit_id, :file_type_id])
  @file_groups.each do |fg|
    #prepare for joins
    fg[:collection_title] = @collections.detect { |c| c[:id] == fg[:collection_id] }[:title]
    fg[:production_unit_title] = @production_units.detect { |pu| pu[:id] == fg[:production_unit_id] }[:title]
    fg[:file_type_name] = @file_types.detect { |ft| ft[:id] == fg[:file_type_id] }[:type]
  end
end

def create_file_groups
  puts "Existing File Groups: #{FileGroup.count}"
  puts "Input Size: #{@file_groups.count}"
  @file_groups.each do |fg|
    collection = Collection.find_by_title(fg[:collection_title])
    production_unit = ProductionUnit.find_by_title(fg[:production_unit_title])
    file_type = FileType.find_by_name(fg[:file_type_name])
    raise(RuntimeError, "Can't find associated model") unless collection and production_unit and file_type
    FileGroup.create(:collection_id => collection.id, :production_unit_id => production_unit.id,
                     :file_type_id => file_type.id)
  end
  puts "Total File Groups: #{FileGroup.count}"
end

#read the csv file, returning an array of hashes, each formed according the the fields array
def read_csv(file, fields)
  #read in data and shift off title row
  rows = CSV.read(File.join(Rails.root, 'tmp', 'access-export', file))
  rows.shift #remove title row
  rows.collect do |row|
    Hash.new.tap do |h|
      fields.each_with_index do |field, i|
        if field
          h[field] = row[i]
          if field.to_s.match(/id$/)
            h[field] = h[field].to_i
          end
        end
      end
    end
  end
end