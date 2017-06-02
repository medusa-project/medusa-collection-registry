module CollectionsHelper

  def access_system_select_collection
    AccessSystem.all.collect {|system| [system.name, system.id]}
  end

  def collection_confirm_message
    'This is irreversible. Associated assessments and file groups will also be deleted.'
  end

  def collection_form_tab_list
    %w(descriptive-metadata administrative-metadata rights-metadata subcollections)
  end

  #map collection id to total size
  #TODO at some point we may want to account for when we have related file groups
  def collection_size_hash
    sizes = Collection.connection.select_rows('SELECT collection_id, sum(total_file_size) as size FROM file_groups GROUP BY collection_id')
    Hash.new.tap do |hash|
      sizes.each do |id, size|
        hash[id.to_i] = size.to_f
      end
    end
  end

  def load_collection_file_stats
    fe_thread = Thread.new {@file_extension_hashes = load_collection_file_extension_stats(@collection)}
    ct_thread = Thread.new {@content_type_hashes = load_collection_content_type_stats(@collection)}
    fe_thread.join
    ct_thread.join
  end

end
