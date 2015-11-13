class CfsDirectoryDecorator < BaseDecorator

  def label
    object.path
  end

  def search_cfs_directory_link
    h.link_to(self.path, h.cfs_directory_path(self))
  end

  def search_file_group_link
    if file_group = try(:file_group)
      h.link_to(file_group.title, h.file_group_path(file_group))
    else
      ''
    end
  end

  def search_collection_link
    if collection = try(:collection)
      h.link_to(collection.title, h.collection_path(collection))
    else
      ''
    end
  end

end