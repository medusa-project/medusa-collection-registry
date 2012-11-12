require 'set'
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
        opts = opts.reverse_merge!(:duplicate_files => :error)
        duplicate_file_action = opts[:duplicate_files]
        #find files in source
        entries = Dir[::File.join(source_directory, '*')].collect { |f| ::File.basename(f) }
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
          if medusa_subdirectories.include?(file)
            case duplicate_file_action
              when :error
                raise RuntimeError, "Duplicate file #{file} under #{self.pid}:#{self.name}"
              when :skip
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

      def all_files
        self.files(:rows => 1000000)
      end

      def all_subdirectories
        self.subdirectories(:rows => 1000000)
      end

      def all_file_names
        self.all_files.collect { |f| f.name }
      end

      def all_subdirectory_names
        self.all_subdirectories.collect { |f| f.name }
      end

      def clear_files
        self.all_files.each do |f|
          f.recursive_delete
        end
      end

      def recursive_delete
        self.clear_files
        self.all_subdirectories.each do |sd|
          sd.recursive_delete
        end
        super
      end

    end
  end
end