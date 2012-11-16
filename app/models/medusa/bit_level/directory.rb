require 'set'
require 'fileutils'

module Medusa
  module BitLevel
    class Directory < Medusa::Object
      has_relationship 'bit_level_root_for', :is_bit_level_root_for
      has_relationship 'subdirectory_of', :is_subdirectory_of
      has_relationship 'subdirectories', :is_subdirectory_of, :inbound => true
      has_relationship 'files', :has_directory, :inbound => true

      has_metadata :name => 'properties', :type => NameProperties

      #return collection if this is a bit level root, nil otherwise
      def bit_level_root_for_collection
        self.bit_level_root_for.first
      end

      def name
        self.properties.name
      end

      def name=(name)
        self.properties.name = name
      end

      def ingest(source_directory, opts = {})
        Rails.logger.info("Bit Ingesting Directory #{source_directory}")
        opts = opts.reverse_merge!(:duplicate_files => :error)
        duplicate_file_action = opts[:duplicate_files]
        #find files in source
        entries = Dir[::File.join(source_directory, '*')].collect { |f| ::File.basename(f) }
        entries += Dir[::File.join(source_directory, '.*')].collect { |f| ::File.basename(f) } - ['.', '..']
        source_files = entries.select { |f| ::File.file?(::File.join(source_directory, f)) }
        source_subdirectories = entries.select { |f| ::File.directory?(::File.join(source_directory, f)) }
        #find current files
        medusa_files = self.all_file_names.to_set
        medusa_subdirectories = self.all_subdirectories.each_with_object(Hash.new) do |subdir, hash|
          hash[subdir.name] = subdir
        end
        #handle files
        source_files.each do |file|
          #check name - if dup take appropriate action
          if medusa_files.include?(file)
            case duplicate_file_action
              when :error
                raise RuntimeError, "Duplicate file #{file} under #{self.pid}:#{self.name}"
              when :skip
                Rails.logger.info "Skipping bit ingest of duplicate file #{file} under #{self.pid}:#{self.name}"
                next
              when :replace
                raise RuntimeError, "Replacing duplicate file in bit level store not yet supported"
              else
                raise RuntimeError, 'Unrecognized action for duplicate bit level file'
            end
          end
          Medusa::BitLevel::File.ingest(::File.join(source_directory, file), self)
        end
        #handle directories
        source_subdirectories.each do |source_subdir|
          #create in fedora if needed
          unless medusa_subdirectories[source_subdir]
            medusa_subdir = Medusa::BitLevel::Directory.new(:pid => self.random_pid)
            medusa_subdir.name = ::File.basename(source_subdir)
            medusa_subdir.add_relationship(:is_subdirectory_of, self)
            medusa_subdir.save
            medusa_subdirectories[source_subdir] = medusa_subdir
          end
          #recursively ingest
          medusa_subdirectories[source_subdir].ingest(::File.join(source_directory, source_subdir), opts)
        end

      end

      def export(target_directory)
        FileUtils.mkdir_p(target_directory)
        self.each_file do |f|
          #depends on whether file has content or is empty
          if f.has_content?
            ::File.open(::File.join(target_directory, f.name), 'wb') do |target_file|
              target_file.write f.content
            end
          else
            FileUtils.touch(::File.join(target_directory, f.name))
          end
        end
        self.each_subdirectory do |sd|
          sd.export(::File.join(target_directory, sd.name))
        end
      end

      #note that it's dangerous to do destructive operations (i.e. delete objects) here
      def each_file
        Medusa::BitLevel::File.find_each(self.files_query) do |file|
          yield file
        end
      end

      #note that it's dangerous to do destructive operations (i.e. delete objects) here
      def each_subdirectory
        Medusa::BitLevel::Directory.find_each(self.subdirectories_query) do |subdirectory|
          yield subdirectory
        end
      end

      def all_subdirectories
        Array.new.tap do |subdirectories|
          self.each_subdirectory do |sd|
            subdirectories << sd
          end
        end
      end

      def all_file_pids
        Array.new.tap do |pids|
          Medusa::BitLevel::File.find_in_batches(self.files_query) do |batch|
            batch.each { |item| pids << item['id'] }
          end
        end
      end

      def all_subdirectory_pids
        Array.new.tap do |pids|
          Medusa::BitLevel::Directory.find_in_batches(self.subdirectories_query) do |batch|
            batch.each { |item| pids << item['id'] }
          end
        end
      end

      #will allow deletion as we traverse
      def each_file!
        self.all_file_pids.each do |pid|
          yield Medusa::BitLevel::File.find(pid)
        end
      end

      #will allow deletion as we traverse
      def each_subdirectory!
        self.all_subdirectory_pids.each do |pid|
          yield Medusa::BitLevel::Directory.find(pid)
        end
      end


      def file_count
        Medusa::BitLevel::File.count(:conditions => self.files_query)
      end

      def subdirectory_count
        Medusa::BitLevel::Directory.count(:conditions => self.subdirectories_query)
      end

      def all_file_names
        Array.new.tap do |names|
          self.each_file do |f|
            names << f.name
          end
        end
      end

      def all_subdirectory_names
        Array.new.tap do |names|
          self.each_subdirectory do |sd|
            names << sd.name
          end
        end
      end

      def clear_files
        self.each_file! do |f|
          f.recursive_delete
        end
      end

      def recursive_delete
        self.clear_files
        self.each_subdirectory! do |sd|
          sd.recursive_delete
        end
        super
      end

    end
  end
end