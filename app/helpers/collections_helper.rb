module CollectionsHelper

  def access_system_select_collection
    AccessSystem.order(:name).all.collect {|system| [system.name, system.id]}
  end

  def collection_form_tab_list
    %w(descriptive-metadata administrative-metadata rights-metadata subcollections)
  end

  #map collection id to total size, counting only bit level file groups
  def collection_size_hash
    file_group_info = BitLevelFileGroup.select('collection_id, sum(total_file_size) AS size').group(:collection_id)
    Hash.new.tap do |hash|
      file_group_info.each do |file_group|
        hash[file_group.collection_id] = file_group.size.to_f
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
