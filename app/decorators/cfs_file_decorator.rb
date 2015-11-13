class CfsFileDecorator < BaseDecorator

  def label
    object.relative_path
  end

  def cfs_label
    object.relative_path
  end

  def cfs_type
    'CFS File'
  end

  def fits_button
    if fits_xml
      h.small_view_button(h.fits_cfs_file_path(self, format: :xml))
    else
      h.small_create_button(h.create_fits_xml_cfs_file_path(self, method: :post))
    end
  end

  def search_cfs_file_link
    h.link_to(self.name, h.cfs_file_path(self))
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

  def search_cfs_directory_path
    cfs_directory.path
  end

end