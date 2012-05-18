#This is intended to be mixed in to an Ingestor (and depends on some stuff in Ingestors, like the package root)
#It is to encapsulate some things common to our ContentDm ingests
module Medusa
  class ContentDmIngestor < GenericIngestor

    def uningest
      with_timing do
        retries = 50
        while (retries > 0)
          begin
            collection = Medusa::Set.find(self.collection_pid)
            collection.recursive_delete
            break
          rescue Exception => e
            retries = retries - 1
            raise e if retries == 0
            puts "Got exception #{e}. #{retries} retries left. Restarting in five seconds."
            sleep 5
          end
        end
        puts "Finished uningest with #{retries} retries remaining."
      end
    end

    def collection_pid
      files = self.collection_file_data
      premis_file = files.detect { |f| f[:base] == 'premis_object' }
      premis_file[:pid]
    end

    #this is a general procedure for ingesting a collection with an appropriate tree structure
    #a subclass need only define build_parent and build_asset methods that correctly build and
    #return an unsaved Medusa::Parent or Medusa::Asset and then this method should be able to use
    #those to create the correct fedora structure out of those.
    #Of course for custom use you can just completely override this.
    def ingest
      with_timing do
        fedora_collection = create_collection
        ingest_threads = Array.new
        self.item_dirs.in_groups(self.item_ingest_thread_count, false).each_with_index do |item_group, i|
          t = Thread.new do
            t[:id] = i
            t.abort_on_exception = true
            item_group.each do |item_dir|
              ingest_item(item_dir, fedora_collection)
            end
            puts "THREAD #{t[:id]} FINISHED PROCESSING"
          end
          ingest_threads << t
        end
        puts "Number of threads: #{ingest_threads.count}"
        ingest_threads.each { |thread| thread.join }
        puts "Ingest complete"
        fedora_collection
      end
    end

    def ingest_item(item_dir, collection, retries = 5)
      item_pid = File.basename(item_dir).gsub('_', ':')
      begin
        fedora_item = build_parent(item_dir, item_pid, item_pid)
        puts "ITEM PID: #{fedora_item.pid}"
        fedora_item.add_relationship(:is_member_of, collection)
        fedora_item.save
        puts "Ingested parent #{fedora_item.pid} on thread #{Thread.current[:id]}"
        add_assets_and_children(item_dir, item_pid, fedora_item)
      rescue Exception => e
        puts "Error ingesting item, pid: #{item_pid}"
        if retries > 0
          puts "Trying to delete item"
          recursive_delete_if_exists(item_pid, Medusa::Parent)
          puts "Deleted item if it existed."
          puts "Preparing to try ingesting again"
          sleep 5
          ingest_item(item_dir, collection, retries - 1)
        else
          puts "Out of retries - aborting"
          raise e
        end
      end
    end

    #create and return collection, assuming directory structure convention is met
    #override if customization is needed
    def create_collection
      collection_files = self.collection_file_data
      collection_premis_file = collection_files.detect { |f| f[:base] == 'premis_object' }
      collection_mods_file = collection_files.detect { |f| f[:base] == 'mods' }
      collection_pid = collection_premis_file[:pid]
      do_if_new_object(collection_pid, Medusa::Set) do |collection_object|
        puts "INGESTING COLLECTION:" + collection_pid
        add_xml_datastream_from_file(collection_object, 'PREMIS', collection_premis_file[:original])
        add_mods_and_dc(collection_object, collection_mods_file[:original])
        collection_object.save
        puts "INGESTED COLLECTION: #{collection_pid}"
      end
    end

    #Use any asset directories present in dir to add assets to parent
    #Use any child directories present in dir to add children to parent
    #Recursively call on any children found, depth first
    def add_assets_and_children(dir, item_pid, parent)
      #get the asset subdirs and the child subdirs (ordered correctly)
      #this assumes that the pid suffixes for children are generated numerically in the right order
      subdirectories = subdirs(dir)
      assets = subdirectories.select { |d| leaf_directory?(d) }
      children = (subdirectories - assets).sort_by { |name| File.basename(name).split('.').last.to_i }
      #Make assets and add them to parent_object
      assets.each do |asset_dir|
        asset = build_asset(asset_dir)
        asset.add_relationship(:is_part_of, parent)
        asset.save
        puts "Ingested Asset #{asset.pid} on thread #{Thread.current[:id]}"
      end
      #Make children and add to parent. Recursively process children.
      previous_child = nil
      children.each do |child_dir|
        child = build_parent(child_dir, item_pid)
        child.add_relationship(:is_child_of, parent)
        if previous_child
          child.add_relationship(:has_previous_sibling, previous_child)
        else
          child.add_relationship(:is_first_child_of, parent)
        end
        child.save
        puts "Ingested Parent #{child.pid} on thread #{Thread.current[:id]} "
        previous_child = child
        add_assets_and_children(child_dir, item_pid, child)
      end
    end

    #If file_data is true, take the data in the file file_data[:original] and put it into an XML metadata stream
    #on the given object with stream_name as the dsId.
    #If file_data is false, then if allow_skip is true just skip adding this stream. If allow_skip is false (the default)
    #then an error should be raised.
    def add_metadata(object, stream_name, file_data, allow_skip = false)
      add_xml_datastream_from_file(object, stream_name, file_data[:original]) if file_data or !allow_skip
    end

    #parse the filename, returning a hash which has components for:
    #:pid -> unique id for this content, suitable for medusa pid after small transformation (which we do here)
    #:extension -> extension of filename. Includes '.', e.g. '.jpg', not 'jpg'
    #:base -> rest of the filename. This may be further parseable, but this method doesn't do it.
    #:dir -> directory where the file lies
    #:original - the original filename
    def parse_filename(filename)
      Hash.new.tap do |h|
        h[:original] = filename
        h[:dir] = File.dirname(filename)
        h[:extension] = File.extname(filename)
        parts = File.basename(filename, h[:extension]).split('_')
        uid = parts.pop
        namespace = parts.pop
        h[:pid] = "#{namespace}:#{uid}"
        h[:base] = parts.join('_')
      end
    end

    def collection_file_data
      files = Dir[File.join(self.package_root, 'collection', '*.*')]
      files.collect { |f| parse_filename(f) }
    end

    def item_dirs
      Dir[File.join(self.package_root, '*', '*', '*')]
    end

    def file_data(item_dir)
      files = Dir[File.join(item_dir, '*.*')]
      files.collect { |f| parse_filename(f) }
    end

    def build_parent(dir, item_pid, pid = nil)
      raise RuntimeException, "Subclass responsibility"
    end

    def build_asset(dir)
      raise RuntimeException, "Subclass responsibility"
    end

    def with_timing
      start_time = Time.now
      result = yield
      end_time = Time.now
      puts "Started: #{start_time} Ended: #{end_time} Seconds: #{end_time - start_time} Minutes: #{(end_time - start_time) / 60.0}"
      return result
    end

  end
end