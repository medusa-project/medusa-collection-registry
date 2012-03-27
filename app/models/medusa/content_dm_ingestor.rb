#This is intended to be mixed in to an Ingestor (and depends on some stuff in Ingestors, like the package root)
#It is to encapsulate some things common to our ContentDm ingests
module Medusa
  class ContentDmIngestor < GenericIngestor

    def uningest
      files = self.collection_file_data
      premis_file = files.detect { |f| f[:base] == 'premis_object' }
      pid = premis_file[:pid]
      collection = Medusa::Set.load_instance(pid)
      collection.recursive_delete
    end

    #this is a general procedure for ingesting a collection with an appropriate tree structure
    #a subclass need only define build_parent and build_asset methods that correctly build and
    #return an unsaved Medusa::Parent or Medusa::Asset and then this method should be able to use
    #those to create the correct fedora structure out of those.
    #Of course for custom use you can just completely override this.
    def ingest
      fedora_collection = create_collection
      self.item_dirs.each do |item_dir|
        fedora_item = build_parent(item_dir)
        fedora_item.add_relationship(:is_member_of, fedora_collection)
        fedora_item.save
        add_assets_and_children(item_dir, fedora_item)
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
        puts "INGESTING COLLECTION: " + collection_pid
        add_xml_datastream_from_file(collection_object, 'PREMIS', collection_premis_file[:original])
        add_xml_datastream_from_file(collection_object, 'MODS', collection_mods_file[:original])
        collection_object.save
        puts "INGESTED COLLECTION: #{collection_pid}"
      end
    end

    def add_assets_and_children(dir, parent)
      #get the asset subdirs and the child subdirs (ordered correctly)
      subdirectories = subdirs(dir)
      assets = subdirectories.collect { |d| leaf_directory?(d) }
      children = (subdirectories - assets).sort_by { |name| File.basename(name).split('.').last.to_i }
      #make assets and add them to parent_object
      assets.each do |asset_dir|
        asset = build_asset(asset_dir)
        asset.add_relationship(:is_part_of, parent)
        asset.save
      end
      #make and attach child objects to parent, calling this recursively on the child dirs and objects. Depth first.
      previous_child = nil
      children.each do |child_dir|
        child = build_parent(child_dir)
        child.add_relationship(:is_child_of, parent)
        if previous_child
          child.add_relationship(:has_previous_sibling, previous_child)
        else
          child.add_relationship(:is_first_child_of, parent)
        end
        child.save
        previous_child = child
        add_assets_and_children(child_dir, child)
      end
    end

    #parse the filename, returning a hash which has components for:
    #:pid -> unique id for this content, suitable for medusa pid after small transformation (which we do here)
    #:extension -> extension of filename
    #:base -> rest of the filename. This may be further parseable, but not by this method
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

  end
end