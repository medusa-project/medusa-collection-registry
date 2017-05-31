require 'active_support/concern'
require 'fileutils'
require 'set'
module SunspotExtensions
  extend ActiveSupport::Concern

  module ClassMethods

    def solr_count
      solr_search do
        fulltext ''
      end.total
    end

    #This is to be similar to the clean_index_orphans method provided by Sunspot,
    #except we want it to go both ways, i.e. to both remove orphans and index things
    #that are not indexed yet, and also to work for large indexes on both sides.
    #To do so we'll get ids from both Solr and the DB, write to files, sort the files,
    #then read the files back in keeping track of differences in two sets. Then we can
    #trigger the appropriate action on each set.
    #We also provide the option to just generate the files and leave them on the filesystem
    #for processing by comm, diff
    def solr_sync(generate_files_only: true)
      working_directory = File.join(Dir.tmpdir, "solr_sync_#{self.to_s}_#{UUID.generate}")
      FileUtils.mkdir_p(working_directory)
      puts "Sync working directory: #{working_directory}"
      solr_ids_file = File.join(working_directory, 'solr_ids')
      sorted_solr_ids_file = File.join(working_directory, 'sorted_solr_ids')
      db_ids_file = File.join(working_directory, 'db_ids')
      sorted_db_ids_file = File.join(working_directory, 'sorted_db_ids')
      only_solr_ids_file = File.join(working_directory, 'only_solr_ids')
      only_db_ids_file = File.join(working_directory, 'only_db_ids')
      get_solr_ids(solr_ids_file, sorted_solr_ids_file)
      get_db_ids(db_ids_file, sorted_db_ids_file)
      if generate_files_only
        puts "Sync files in: #{working_directory} for manual inspection."
      else
        analyze_ids(sorted_solr_ids_file, sorted_db_ids_file, only_solr_ids_file, only_db_ids_file)
        remove_orphans(solr_ids_set)
        add_missing(db_ids_set)
      end
    ensure
      FileUtils.rm_rf(working_directory) if Dir.exist?(working_directory) and !generate_files_only
    end

    private

    def get_solr_ids(unsorted_file, sorted_file)
      File.open(unsorted_file, 'w') do |f|
        cursor = '*'
        while true
          search = get_solr_ids_search(cursor)
          search.raw_results.each do |result|
            f.puts result.primary_key
          end
          break if search.results.last_page?
          cursor = search.results.next_page_cursor
        end
      end
      system('sort', '-o', sorted_file, unsorted_file)
    end

    def get_solr_ids_search(cursor)
      search do
        fulltext ''
        paginate cursor: cursor, per_page: 100000
      end
    end

    #uses postgresql_cursor
    def get_db_ids(unsorted_file, sorted_file)
      File.open(unsorted_file, 'w') do |f|
        select(:id).order(:id).each_row do |row|
          f.puts row['id'].to_s
        end
      end
      system('sort', '-o', sorted_file, unsorted_file)
    end

    def analyze_ids(solr_ids_file, db_ids_file, only_solr_ids_file, only_db_ids_file)
      system("comm -2 -3 '#{solr_ids_file}' #{db_ids_file} > #{only_solr_ids_file}")
      system("comm -1 -3 '#{solr_ids_file}' #{db_ids_file} > #{only_db_ids_file}")
    end

    def remove_orphans(only_solr_ids_file)
      File.open(only_solr_ids_file).each_line do |id|
        id.chomp!
        new.tap do |object|
          new.id = id
          object.solr_remove_from_index
        end
      end
      Sunspot.commit
    end

    def add_missing(only_db_ids_file)
      File.open(only_db_ids_file).each_line do |id|
        id.chomp!
        Sunspot.index find(id)
      end
      Sunspot.commit
    end

  end
end
